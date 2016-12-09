%% Basic first model of locust movement
% Constraints:
%- constant speed
%- few agents
%- periodic boundary conditions
%- No "faulty velocity/position perception" of the locusts.

%Description:
%We want to make an evolutionary algorithm where we use fitness and
%generations to derive the optimal behaviour (W_a & W_m) of locusts.
%We can only get the optimal behaviour for a specific density, so in the
%end, we will have to run our model over many different densities.
%Right now W_a and W_m is set to constants but in the evolutionary
%algorithm me want each locust to be randomed initial W_a and W_m.

clear all;
clc;
global gSize sightRadius;   %make global so that functions do not need them as input.
adskfjhasdlkfh
%Parameters
sightRadius = 10;   % how close the locusts has to be to interact with each other.
gSize = 20;         % grid size
N = 100;            % nbr agents
s = 2;              % speed of agents
timesteps = 100;    % how many timesteps to take
dt = 0.5;           % time step
W_a = -5;           % reaction to approaching locusts
W_m = 5;            % reaction to moving away locusts
W_r = 2;            % repelling force constant.
repulsionRadius = 2;% how close locusts has to be before repelling force sets in.

% Variables defined from parameters
agentAcc = zeros(2, N);
newAngles = zeros(1,N);
newAgentVel = zeros(2, N);

%For testing (can remove later)
% radiusPlot(1:N) = sightRadius;

% ------------ Initialization ------------
% Random agent initial values
x = rand(1,N)*gSize;
y = rand(1,N)*gSize;
angles = rand(1,N)*2*pi;                    % velocity direction
agentVel = s*[cos(angles); sin(angles)];    % initial velocity


for i_time = 1:timesteps
    
    %expands grid in order to use boundary conditions (see function
    %description for more detail)
    [x2, y2, ID2] = ExpandGridForBoundaryConditions(x, y);
    
    % This FOR-LOOP Calculates and updates Forces
    for i = 1:N
        
        agentID = 1:N;                                  %used to get the velocity related to locusts later on.
        
        %Get all relative positions to locust i
        r = [x - x(i); y - y(i)];
        agentID(i) = [];                                %remove comparison to it self
        r(:,i) = [];
        
        %IF locust i is so close to the boundary that it's "sight" should
        %reach over the boundary we have to also take in to account the
        %expanded grid.
        if (x(i)<sightRadius || x(i)>gSize-sightRadius || y(i)<sightRadius || y(i)>gSize-sightRadius)    %if we need to think about periodic boundary conditions
            %x2,y2,ID2 comes from expanding the grid for taking the
            %boundary conditions in to account in an easy way.
            agentID = [agentID, ID2];
            r = [r, [x2-x(i); y2-y(i)]];
        end
        
        %get distance between locusts and filter out the, for locust i,
        %important other locusts
        r_dist = sqrt(sum(r.^2));                       %distance between two agents
        agentsOfInterest = r_dist < sightRadius;        %save only agents that are close enough
        agentID = agentID(agentsOfInterest);            %get list of the interesting agents
        nbrInterestingAgents = sum(agentsOfInterest);
        r = r(:, agentsOfInterest);
        r_dist = r_dist(:, agentsOfInterest);
        
        %Get relative velocity between locust i and the important locusts
        v = zeros(2,nbrInterestingAgents);
        for j = 1:nbrInterestingAgents
            v(:,j) = agentVel(:,i) - agentVel(:, agentID(j) );
        end
        
        %in this FOR-LOOP calculate forces resulting from approaching and
        %moving awway locusts
        relVel = zeros(1, nbrInterestingAgents);
        f_aANDm = zeros(2, nbrInterestingAgents);
        nbrInSightRadius = 0;
        nbrInrepellingRange = 0;
        for j = 1:nbrInterestingAgents
            relVel(j) = v(:,j)'*r(:,j)/r_dist(j);
            if( r_dist(j) ~= 0)
                f_aANDm(:,j) = relVel(j)*r(:, j)./r_dist(j);
                nbrInSightRadius = nbrInSightRadius + 1;
            end
        end
        f_aANDm(:, relVel > 0) = f_aANDm(:, relVel > 0)*W_m;     %moving away
        f_aANDm(:, relVel < 0) = f_aANDm(:, relVel < 0)*W_a;     %approaching
        f_aANDm = f_aANDm/nbrInSightRadius;

        %calculate forces resulting from locusts repelling force (force
        %because they are too close to each other).
        nbrInRepellingRange = sum(r_dist < repulsionRadius);
        if(nbrInRepellingRange ~= 0)
            f_r = sum(r(:,r_dist < repulsionRadius), 2);
            f_r = f_r * -W_r*s/nbrInRepellingRange;
        else
            f_r = [0;0];
        end

        %get forces in theta- (angle-) direction
        forceDirection = [-sin(angles(i)), cos(angles(i))];
        f_theta = sum(forceDirection*f_aANDm);                  %from approaching and moving away locusts
        f_theta = f_theta + forceDirection*f_r;                 %from repelling agents

        %update velocity
        if( ~isempty(f_theta) )
            newAngles(i) = angles(i) + f_theta*dt;
        else
            newAngles(i) = angles(i);
        end
        newAgentVel(:,i) = s*[cos(newAngles(i)); sin(newAngles(i))];
    end

    %Update old values
    agentVel = newAgentVel;
    angles = newAngles;
    x = x + agentVel(1,:)*dt;
    y = y + agentVel(2,:)*dt;
    x = mod(x-1, gSize) + 1;                                   %take care of periodic boundary conditions
    y = mod(y-1, gSize) + 1;
    
%FOR TESTING - Plot new velocities to see effect
%     plot(x,y,'.')
%     quiver(x,y,newAgentVel(1,:), newAgentVel(2,:), 0, 'r');
%     axis([0 gSize 0 gSize]);
%     drawnow
%     viscircles([x',y'], radiusPlot);
%     waitforbuttonpress
    
    %Plot agents with vectors
    hold off
%     quiver(x,y,agentVel(1,:), agentVel(2,:), 0);
    plot(x,y,'.')
    axis([0 gSize 0 gSize]);
    drawnow
end
