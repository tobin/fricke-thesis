for offset=[1000 15]
    clf
    % prepare some variables
    par = struct('Pin', 1);
    par = paramL1(par);
    par = paramEligo_00(par);
    
    opt = optEligo(par);
    opt = probesEligo_00(opt, par);
    
    % Number of sweep positions to consider
    Nsweep = 500+1;
    
    % Maximum DARM offset to check
    dLmMax = offset * 1e-12;
    
    nEX = getDriveNum(opt, 'EX');
    nEY = getDriveNum(opt, 'EY');
    nOMCt = getProbeNum(opt, 'OMCT DC');
    
    pos = zeros(opt.Ndrive, 1);
    pos(nEX) =  dLmMax/2;
    pos(nEY) = -dLmMax/2;
    
    % Run Optickle
    [xPos, sigDC, fDC] = sweepLinear(opt, -pos, pos, Nsweep);
    
    % Extract some signals of interest
    DARM = (xPos(nEX,:)-xPos(nEY,:));  % DARM offset
    P_AS   = sigDC(nOMCt,:);          % Power at the AS port
    
    if offset < 20
        plot(DARM * 1e12, P_AS * 1000, 'linewidth', 2);
        ylabel('1000 \times P_{AS} / P_{IN}');
        ylim([0 max(P_AS)*1000*1.1])
    else
        plot(DARM * 1e12, P_AS, 'linewidth', 2);
        ylabel('P_{AS} / P_{IN}');    
        ylim([0 max(P_AS)*1.1])
    end
    xlabel('DARM offset [picometers]');
    xlim(offset*[-1 1]);

    lgrid(cgrid);    
    
    papersize = (470/72)*[0.5 0.37];
    margins = [36 36 -12 -8]/72;
    filename = sprintf('../figures/darmfringe-%d.pdf', offset);
    print_for_publication(filename, papersize, margins);
end

