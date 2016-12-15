function [ polarization ] = GetPolarization( agentVelocity, speed )
% GetPolarization calculated the polarization from a 2xN velocity matrix;

N = length(agentVelocity);
sumVel = sum(agentVelocity, 2);
polarization = sqrt(sum(sumVel.^2))/(N*speed);

end

