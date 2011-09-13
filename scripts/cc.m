%% Coupled cavity transfer function

c = 299792458;

f = logspace(log10(0.001), log10(10e3), 100);
%f = linspace(37521-10, 37521+10, 600);

omega = 2*pi*f;

r1 = sqrt(0.971);              % ITM
r2 = sqrt(1 - 200e-6);         % ETM + cavity losses
r3 =  (r1 - r2)/(1 - r1*r2);   % RM = critical coupling, approx sqrt(0.973)

L_arm = 3995;
L_rc  = 9;

fsr_arm = c/(2*L_arm);
fsr_rc  = c/(2*L_rc);

phi_arm = (1/2) * omega / fsr_arm;   % one-way phase
phi_rc  = (1/2) * omega / fsr_rc;

r_arm = (r1 - r2 *     exp(2i*phi_arm)) ./ (1 - r1 * r2    * exp(2i*phi_arm));

r_rc =  (r3 - r_arm .* exp(2i*phi_rc)) ./ (1 - r3 * r_arm .* exp(2i*phi_rc));

fc_arm = -fsr_arm * log(r1*r2) / (2*pi)
fc_rc  = -fsr_rc  * log(r3*r3) / (2*pi)

finesse_arm = fsr_arm / fc_arm / 2
finesse_rc  = fsr_rc / fc_rc / 2

finesse_rc = -pi / log(r3*r3);

fcc_rana = fc_arm / finesse_rc 

fcc =    -fsr_arm * log((r1 - r3)/(1-r1*r3)*r2) / (2*pi)   % Malik 4.82

s = 1i*omega;
%subplot(2,1,1);
loglog(f, abs(r_rc), 'o-',...           % full numerical thing
       f, abs(s ./ (s + 2*pi*fcc)),'-');    % single pole model
% grid on
% subplot(2,1,2);
% semilogx(f, angle(r_rc)*180/pi,'.');
% set(gca,'YTick', 45*(-4:4));
