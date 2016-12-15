function [ polarization ] = GetPolarization( agentVelocity )
% GetPolarization calculated the polarization from a 2xN velocity matrix;

N = length(agentVelocity);
sumVel = sum(sum(agentVelocity, 2));
polarization = sqrt(sumVel.^2)/N;

end

