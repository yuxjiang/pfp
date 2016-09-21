function [bacc, point, t] = pfp_bacc(pred, ref, varargin)
    %PFP_BACC Balanced accuracy
    %
    % [bacc, point, t] = PFP_BACC(pred, ref, varargin);
    %
    %   Returns the best balanced accuracy.
    %
    % Input
    % -----
    % (required)
    % [double]
    % pred: An n-by-1 predicted score from the predictor. where n is the number
    %       of instances. Note that scores must be within the range [0, 1].
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
    % bacc:     The best balanced accuracy.
    %
    % [double]
    % point:    The corresponding (bacc, tau) which yields the 'bacc'.
    %
    % [double]
    % t:        The best corresponding threshold.
    %
    % Dependency
    % ----------
    % [>] pfp_bacccurve.m
    % [>] pfp_baccc.m

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
    [bacc, point, t] = pfp_baccc(pfp_bacccurve(pred, ref, 'tau', p.Results.tau));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:23:15 PM E
