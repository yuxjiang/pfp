function [acc, point, t] = pfp_acc(pred, ref, varargin)
    %PFP_ACC Accuracy
    %
    % [acc, point, t] = PFP_ACC(pred, ref, varargin);
    %
    %   Returns the best accuracy.
    %
    % Input
    % -----
    % (required)
    % [double]
    % pred: An n-by-1 predicted score from the predictor. where n is the number of
    %       instances. Note that scores must be within the range [0, 1].
    %
    % [logical]
    % ref:  An n-by-1 binary vector, which is the reference.
    %
    % (optional)
    % [double]
    % tau:  A 1-by-k vector of thresholds.
    %
    % Output
    % ------
    % [double]
    % acc:      The best accuracy.
    %
    % [double]
    % point:    The corresponding (acc, tau) which yields the 'acc'.
    %
    % [double]
    % t:        The best corresponding threshold.
    %
    % Dependency
    % ----------
    % [>] pfp_acccurve.m
    % [>] pfp_accc.m

    % check inputs {{{
    if nargin < 2
        error('pfp_acc:InputCount', 'Expected at least 2 inputs.');
    end

    % pred
    validateattributes(pred, {'double'}, {'>=', 0, '<=', 1}, '', 'pred', 1);
    [n, m] = size(pred);

    % ref
    validateattributes(ref, {'logical'}, {'ncols', 1, 'numel', n}, '', 'ref', 2);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultTAU = [];
    addParameter(p, 'tau', defaultTAU, @(x)isnumeric(x));
    parse(p, varargin{:});
    % }}}

    % get curve(s) and their acc {{{
    [acc, point, t] = pfp_accc(pfp_acccurve(pred, ref, 'tau', p.Results.tau));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:21:36 PM E
