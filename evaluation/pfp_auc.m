function [auc] = pfp_auc(pred, ref, varargin)
    %PFP_AUC Area under the ROC (curve)
    %
    % [auc] = PFP_AUC(pred, ref, varargin);
    %
    %   Returns the estimated AUC of a predictor.
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
    % (optional) Name-value pairs.
    % [double]
    % tau:  A vector of k thresholds. If given an empty vector, this function
    %       uses all unique values of scores.
    %       default: []
    %
    % Output
    % ------
    % [double]
    % auc:  The area under the ROC curve.
    %
    % Dependency
    % ----------
    % [>] pfp_roccurve.m
    % [>] pfp_aucc.m

    % check inputs {{{
    if nargin < 2
        error('pfp_auc:InputCount', 'Expected at least 2 inputs.');
    end

    % pred
    validateattributes(pred, {'double'}, {'ncols', 1, '>=', 0, '<=', 1}, '', 'pred', 1);
    n = length(pred);

    % ref
    validateattributes(ref, {'logical'}, {'ncols', 1, 'numel', n}, '', 'ref', 2);
    % }}}

    % extra inputs {{{
    p = inputParser;
    defaultTAU = [];
    addParameter(p, 'tau', defaultTAU, @(x)isnumeric(x));
    parse(p, varargin{:});
    % }}}

    % get curve(s) and compute AUC(s) {{{
    auc = pfp_aucc(pfp_roccurve(pred, ref, 'tau', p.Results.tau));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:22:14 PM E
