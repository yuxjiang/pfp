function [p] = pfp_randomfield(E, known, burnin, budget)
    %PFP_MRF Markov random field
    %
    % [p] = PFP_MRF(E, known, burnin, budget);
    %
    %   Esitmates the probability of each variable being one using Markov random
    %   field method. I.e., it estimates the parameter THETA of each Bernoulli
    %   random variable. using Gibbs sampling.
    %
    % Input
    % -----
    % [double]
    % E:        An non-negative n-by-n (weighted) adjacency matrix.
    %
    % [double]
    % known:    An n-by-1 vector which specifies the observed (fixed) value of a
    %           subset of n random variables.
    %           1   - known to be one (positive)
    %           0   - known to be zero (negative)
    %           NaN - unknown (those need to be estimated)
    %
    % [double]
    % burnin:   The burn-in time of the algorithm.
    %
    % [double]
    % budget:   Maximum number of iteration.
    %
    % Output
    % ------
    % [double]
    % p:    An n-by-1 estimated parameters for each random variable.

    % check inputs {{{
    if nargin ~= 4
        error('pfp_randomfield:InputCount', 'Expected 4 inputs.');
    end

    % E
    validateattributes(E, {'double'}, {'square', '>=', 0}, '', 'E', 1);
    n = size(E, 1);

    % known
    validateattributes(known, {'double'}, {'numel', n}, '', 'known', 2);

    % burnin
    validateattributes(burnin, {'double'}, {'positive'}, '', 'burnin', 3);

    % budget
    validateattributes(budget, {'double'}, {'>', burnin}, '', 'budget', 4);
    % }}}

    % initialization {{{
    p                = zeros(n, 1);
    unknown          = find(isnan(known));
    m                = length(unknown);
    samples          = known;
    samples(unknown) = rand(m,1) > .5;
    Nei              = full(E(unknown,:) ~= 0);
    fullE            = full(E(unknown,:));
    % }}}

    % Gibbs sampling {{{
    for i = 1:budget
        fprintf('iteration %d/%d\n', i, budget);
        r = rand(m, 1);
        for j = 1:m
            value = fullE(j, Nei(j,:)) * samples(Nei(j,:));
            if r(j) < value / (value + 1);
                samples(unknown(j)) = 1;
            else
                samples(unknown(j)) = 0;
            end
        end
        if i > burnin
            k = i - burnin;
            p = (p * (k-1) + samples) / k;
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 12:54:08 PM E
