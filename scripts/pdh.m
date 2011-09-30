
c = 299792458;

r1 = sqrt(0.971);              % ITM
r2 = sqrt(1 - 200e-6);         % ETM + cavity losses

L = 3995;
fsr = c/(2*L);

f_c = fsr * log(r1*r2) / (2*pi);
r_c = @(phi) (r1 - r2 * exp(2i*phi)) ./ (1 - r1 * r2  * exp(2i*phi));

Gamma = 0.1;

phi = linspace(-0.01, 0.01, 301)*pi;

phi_mod = pi/2 - pi/4;

I  = 1i * (BesselJ(0,  Gamma) * r_c(phi)) ...
        .* ( ...
               BesselJ(+1, Gamma) * r_c(phi + phi_mod) + ...
              -BesselJ(-1, Gamma) * r_c(phi - phi_mod) ...
           );
       
Q =  1 * (BesselJ(0,  Gamma) * r_c(phi)) ...
        .* ( ...
               BesselJ(+1, Gamma) * r_c(phi + phi_mod) + ...
              +BesselJ(-1, Gamma) * r_c(phi - phi_mod) ...
           );      

I = real(I)/Gamma;
Q = real(Q)/Gamma;

%%
clf
g = sqrt(1 - r1^2) / (1 - r1*r2);
F = 4*r1*r2/(1-r1*r2)^2;

plot(phi/pi, g^2./(1+F*sin(phi).^2), 'color', 'r', 'linewidth', 2);

lgrid(cgrid);

xlabel('detuning [1/fsr]');
ylabel('intra-cavity power buildup');

papersize = (470/72)*[0.5 0.37];
margins = [50 36 -8 -8]/72;
filename = '../figures/cav-power.pdf';
print_for_publication(filename, papersize, margins);

%%
clf
plot(phi/pi, I, 'linewidth', 2);
line(+[1 1]*pi*f_c/fsr/3, get(gca, 'ylim'), 'color', [0 0 0], 'linestyle', '--');
line(-[1 1]*pi*f_c/fsr/3, get(gca, 'ylim'), 'color', [0 0 0], 'linestyle', '--');
lgrid(cgrid);

xlabel('detuning [1/fsr]');
ylabel('PDH error signal [1/Pin/\Gamma]');

filename = '../figures/cav-pdh.pdf';
print_for_publication(filename, papersize, margins);
