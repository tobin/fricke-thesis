function intensity_noise
%% Laser Intensity Noise Coupling

for ii=0:1
% Set up Optickle parameters
close all
par = paramL1;
if ii==1
    par.mass = inf;
end
par = paramEligo_00(par);
opt = optEligo(par);
opt = probesEligo_00(opt, par);

opt = addProbeOut(opt, 'AM DC', 'Mod2', 'out', 0, 0);

% Frequency grid
f = [0 logspace(log10(0.1), log10(10e3), 211)];

offDC = 10e-12;                    % Some DARM offset
pos = zeros(opt.Ndrive, 1);
nEX = getDriveIndex(opt, 'EX');
nEY = getDriveIndex(opt, 'EY');
pos(nEX) =  offDC / 2;
pos(nEY) = -offDC / 2;

opts{1} = opt;

% Turn off sidebands
opt = setOpticParam(opt, 'Mod1', 'aMod', 0);
opt = setOpticParam(opt, 'Mod2', 'aMod', 0);
opts{2} = opt;

% Turn on ONLY sidebands
aMod = zerobess('J',0,1);
opt = setOpticParam(opt, 'Mod1', 'aMod', 1i*aMod);
opt = setOpticParam(opt, 'Mod2', 'aMod', 0);  % don't need no 61 Mhz
opts{3} = opt;

% 
% par = paramL1;
% par.mass = inf;
% % turn off carrier
% par.Laser.vArf(par.Laser.vFrf == 0) = 0;   
% % turn on sideband source for 25 MHz sideband
% par.Laser.vArf(abs(par.Laser.vFrf + 25e6)<1e6) =  -1;
% par.Laser.vArf(abs(par.Laser.vFrf - 25e6)<1e6) =  1;
% par = paramEligo_00(par);
% opt = optEligo(par);
% opt = probesEligo_00(opt, par);
% opt = addProbeOut(opt, 'AM DC', 'AM', 'out', 0, 0);
% opt = setOpticParam(opt, 'Mod1', 'aMod', 0);
% opt = setOpticParam(opt, 'Mod2', 'aMod', 0);
% 
% opts{3} = opt;
clear opt

for ii=1:3
    [fDC{ii}, sigDC{ii}, sigAC{ii}, mMech{ii}, noiseAC{ii}] = ...
        tickle(opts{ii}, pos, f);
end

%% Sanity check

hold off
for ii=1:length(opts)    
    nAMdrive  = getDriveNum(opts{ii}, 'AM');
    nAMprobe  = getProbeNum(opts{ii}, 'AM DC');
    semilogx(f, abs(getTF(sigAC{ii}, nAMprobe, nAMdrive))/sigDC{ii}(nAMprobe)/2, 'LineWidth', 10-2*ii);
    hold all
end
hold off
legend('1','2','3');
%% Optical gain
opt = opts{1};

nOMCprobe = getProbeNum(opt, 'OMCT DC');
 
% extract some optical spring related stuff
optickle_gain = getTF(sigAC{1}, nOMCprobe, nEX) - ...
                getTF(sigAC{1}, nOMCprobe, nEY);

detuning = offDC;
S_DC = 40 * par.Laser.Power * 2 * opt.k * 137 * ...
       cos(2 * opt.k * 137 * detuning) * ...
       sin(2 * opt.k * 137 * detuning);
   
detuning = pos(nEX);  
P_BS = 40 * par.Laser.Power;    
k_m =  par.w^2 * par.mass;            
k_o =  64 * (220^2) * 137 * P_BS * detuning / (opt.c * opt.lambda^2);
k_d = (k_m^2 - k_o^2) / (-2 * k_o);

loglog(f, abs(optickle_gain), ...
       f,  S_DC ./ abs(1 + 1i*f/89));
   
%% Get the transfer function (W at OMC T)/(RIN at AM Modulator)

traces = {};

hold off
for ii=1:length(fDC),
    % find the DC Field number
    DCfield = find(get(opts{ii},'vFrf')==0);
    nAMdrive  = getDriveNum(opts{ii}, 'AM');
    nOMCprobe = getProbeNum(opts{ii}, 'OMCT DC');
    nAMprobe  = getProbeNum(opts{ii}, 'AM DC');
    nLaserProbe = getProbeNum(opts{ii}, 'LASER DC');
    Mod2field = getFieldOut(opts{ii}, 'Mod2', 'out');
    switch ii
        case 1
            atten = 1;
        case 2
            atten = (besselj(0, par.Mod.g1) * besselj(0, par.Mod.g2))^2;
        case 3
            atten = 2 * (besselj(1, par.Mod.g1) * besselj(0, par.Mod.g2))^2;
    end
    
    traces{ii}.x = f;
    traces{ii}.y =  atten * getTF(sigAC{ii}, nOMCprobe, nAMdrive) ./ ...
                            getTF(sigAC{ii}, nAMprobe,  nAMdrive);
    % (W OMC)/(d Amp/Amp) = Amp * (W OMC) / d Amp
     %semilogx(f, db(getTF(sigAC{ii}, nOMCprobe, nAMdrive)/sigDC{ii}(nAMprobe)/2), ...
    %     'LineWidth', 5);    
end

for ii=1:length(traces)   
%    subplot(2,1,1);
    semilogx(traces{ii}.x, db(traces{ii}.y), 'linewidth', 2);
    hold all
%    subplot(2,1,2);
%    semilogx(traces{ii}.x, angle(traces{ii}.y) * 180/pi, '.');
%    hold all
end
%set(gca, 'ytick', 45 * (-4:4));
%hold off
%subplot(2,1,1);
hold off

opt = opts{1};
DCfield = find(get(opt,'vFrf')==0);
P_carrier = abs(fDC{1}(Mod2field, DCfield))^2;
P_omc = sigDC{1}(nOMCprobe);
line(get(gca,'XLim'), [1 1] * db(P_omc/P_carrier), 'color', [0 0 0], 'linestyle', '--', 'linewidth', 1);
%line(get(gca,'XLim'), [1 1] * db((2/(k_d * opt.c)) * 36 * 137 * S_DC), 'linestyle', '--', 'linewidth', 1);

% find out how much RF power there is in the first place
RFpower = (1 - besselj(0,par.Mod.g1)^2);
% find out how much is coupled into the interferometer
coupling = 1 - abs(fDC{1}(getFieldOut(opt, 'PR', 'bk'),:) ./ fDC{1}(getFieldIn(opt, 'PR', 'bk'),:)).^2;

% get the RF attenuation by the OMC
vfRf = get(opt, 'vFrf');
[~, nfRfDC] = min(abs(vfRf));         % find the carrier field
[~, nfRfSB] = min(abs(vfRf - 25e6));  % find an RF sideband

RFatt = abs(fDC{1}(getFieldIn(opt,  'OMCa', 'bk'), nfRfSB) ./ ...
            fDC{1}(getFieldOut(opt, 'OMCb', 'bk'), nfRfSB))^2;
line(get(gca,'XLim'), db([1 1]*RFpower/RFatt), 'color', [0 0 0], 'linestyle', '--', 'linewidth', 1);

% hold all
% H = (P_omc/P_carrier) ./ (1 + 1i * f/1.0)   ./ (1 + 1i * f/85);
% plot(f, db(H));
% hold off
%%

xlabel('frequency [Hz]');
ylabel('Watts per Watt [dB]');
legend('carrier + sidebands', 'carrier only', 'sidebands only');
set([gca;findall(gca, 'Type','text')], 'FontSize', 12)
%orient landscape
xlim([min(f), max(f)]);
ylim([-130 6]);
title('laser intensity noise coupling to DC readout');
% set(gcf, 'PaperSize', [7.5 4], 'PaperPositionMode', 'auto');
% set(gcf, 'PaperPosition', [0 0 7.5 5])
% set(gcf, 'units', 'inches', 'Position', [0 0 7.5 5]);
% %make_figure_good
% make_figure_good(ifo)
my_make_figure_good()
if isinf(par.mass)
    print -dpdf ../figures/intensity_noise_contributions_without_rp.pdf
else
    print -dpdf ../figures/intensity_noise_contributions.pdf
end

end

end


function my_make_figure_good()
% KLUDGE, I know

a = gca;
c = cgrid;
%lgrid(c);

doReplaceYticks = false;

mode = 'thesis';

if strcmp(mode, 'paper')
    fontsize = 8;
else
    fontsize = 10;
end
set([gca; findall(a, 'Type','text')], 'FontSize', fontsize);


pts_per_inch = 72.26999;
if strcmp(mode, 'paper')
    columnwidth =  0.5 * 446.39996 / pts_per_inch;
else
    columnwidth = 6.5;
end

height = (4/7.5)*columnwidth;

margin_junk = 45 / pts_per_inch;

% if strcmp(mode, 'paper')
%     if strcmp(ifo, 'H1')
%         width = columnwidth - margin_junk / 2;
%     else
%         width = columnwidth + margin_junk / 2;
%     end
% else
    width = columnwidth;
%end

set(gcf, 'PaperSize', [width height]);
set(gcf, 'PaperPosition', [0 0 get(gcf, 'PaperSize')]);

margin_lft = margin_junk;
% if strcmp(ifo, 'H1') && strcmp(mode, 'paper')
%     margin_lft = 0;
% else   
%end
margin_bot = 30/pts_per_inch;
margin_top = 16/pts_per_inch;
margin_rgt =  1/pts_per_inch;

newpos =  [margin_lft margin_bot, ...
     (get(gcf, 'PaperSize') - [(margin_lft + margin_rgt) (margin_top + margin_bot)])];
set([c a], 'Units', 'inches', ...
           'Position', newpos);
       
end
