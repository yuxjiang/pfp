function [X, mu, sigma] = pfp_zscorenrm(X, mu, sigma)
    %PFP_ZSCORENRM Z-score normalization
    %
    % [X, mu, sigma] = PFP_ZSCORENRM(X);
    %
    %   Normalizes data matrix X using z-score method.
    %
    % [X, mu, sigma] = PFP_ZSCORENRM(X, mu);
    % [X, mu, sigma] = PFP_ZSCORENRM(X, mu, sigma);
    %
    %   Normalizes data matrix X using specified mean and standard deviation.
    %
    % Input
    % -----
    % [double]
    % X:    An n-by-m data matrix.
    %
    % (optional)
    % [double]
    % mu:       A 1-by-m vector of desired mean.
    %           default: mean(X, 1);
    %
    % [double]
    % sigma:    A 1-by-m vector of desired standard deviation.
    %           default: std(X, [], 1);
    %
    % Output
    % ------
    % [double]
    % X:        An n-by-m resulting data matrix.
    %
    % [double]
    % mu:       A vector of "m" means for each feature (columns).
    %
    % [double]
    % sigma:    A vector of "m" standard deviations for each feature.

    % check inputs {{{
    if nargin < 1 || nargin > 3
        error('pfp_zscorenrm:InputCount', 'Expected 1 to 3 inputs.');
    end

    if nargin < 3
        sigma = std(X, [], 1);
    end

    if nargin < 2
        mu = mean(X, 1);
    end

    % X
    validateattributes(X, {'double'}, {'nonempty'}, '', 'X', 1);
    m = size(X, 2);

    % mu
    validateattributes(mu, {'double'}, {'vector', 'numel', m}, '', 'mu', 2);

    % sigma
    validateattributes(sigma, {'double'}, {'vector', 'numel', m}, '', 'sigma', 3);
    % }}}

    % normalization {{{
    % check for zero std
    sigma(sigma < 1e-8) = 1e8; % set an arbitrary positive number

    X = bsxfun(@minus, X, mu);
    X = bsxfun(@rdivide, X, sigma);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:41:03 PM E
