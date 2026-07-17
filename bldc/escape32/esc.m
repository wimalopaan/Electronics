% Copyright (C) 2019 - 2026 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

% procedure:
% first:
% set voltage
% set motor constants: pp, kv
% test motor for sine-range: increase sine-power to reach full range without stutter
% choose prot_stall as maximum of the above value
% set sine_range: choose in a way that the transition-point is a bit above prot_stall
% afterwards:
% adjust duty_min to meet transition point
% try to reduce sine_power

% example
% sine_erpm_max = 1500, sine_power = 15
% prot_stall = 1500
% sine_range = 8
% duty_min = 2
% end of example

% customizable settings

voltage = 11.1;

pp = 7;  % motor
kv = 200;

thr_min = 0;  
thr_max = 100; 

duty_min = 0;
duty_max = thr_max;

sine_range = 10; % [0, 25]
prot_stall = 1500   ; % 2300 is used, if parameter prot_stall is not set, range [1500, 3500]

% end of settings

erpm_max = voltage * kv * pp * duty_max / 100;
erpm_min = voltage * kv * pp * duty_min / 100;
erpm_delta = erpm_max - erpm_min;

erpm_sr = erpm_delta * (sine_range / 100) + erpm_min; % normal-mode erpm at throttle=sine_range

m = (erpm_max - prot_stall) / (thr_max - sine_range); % slope of normal-mode function through transition-point [sine_range, prot_stall]
erpm0 = prot_stall - m * sine_range; % fictive erpm for throttle==0
duty0 = erpm0 / (voltage * kv * pp) * 100; % duty_min needed to make normal-mode funtion trough transition-point

thr_prot_stall = (prot_stall) / m;

printf("erpm(sine_range): %f\n", erpm_sr);
printf("diff=prot_stall-erpm(sine_range): %f\n", (prot_stall - erpm_sr));
printf("duty0: %f, erpm0: %f\n", duty0, erpm0);
printf("thr(prot_stall): %f\n", thr_prot_stall);


figure(1);

plot([thr_min, thr_max], [erpm_min, erpm_max], "b", "linewidth", 3, % the normal-mode 
     [thr_min, sine_range], [0, prot_stall], "r",  "linewidth", 3, % sine-mode
     sine_range, prot_stall, "or", "linewidth", 3, "markersize", 10, % transition-point
     sine_range, erpm_sr, "ob", "linewidth", 3, % projected transition-point
     [thr_min, thr_max], [prot_stall, prot_stall], ":c", % prot_stall line
     [thr_min, thr_max], [erpm0, erpm_max], "g", "linewidth", 3, % adjusted notmal-mode (using adapted duty_min = duty0 -> erpm0)
     0, erpm0, "og", "linewidth", 3, % projected transition-point
     [sine_range, sine_range], [0, erpm_max], ":", "linewidth", 3); % region divisor: sine-mode to the left, normal-mode to the right
axis([0, 25, 0, 5000]);

figure(2);

plot([thr_min, thr_max], [erpm_min, erpm_max], "b", "linewidth", 3, % the normal-mode 
     [thr_min, sine_range], [0, prot_stall], "r",  "linewidth", 3, % sine-mode
     sine_range, prot_stall, "or", "linewidth", 3, "markersize", 10, % transition-point
     sine_range, erpm_sr, "ob", "linewidth", 3, % projected transition-point
     [thr_min, thr_max], [erpm0, erpm_max], "g", "linewidth", 3, % adjusted notmal-mode (using adapted duty_min = duty0 -> erpm0)
     0, erpm0, "og", "linewidth", 3, % projected transition-point
     [sine_range, sine_range], [0, erpm_max], ":", "linewidth", 3); % region divisor: sine-mode to the left, normal-mode to the right
axis([0, 100, 0, 30000]);
