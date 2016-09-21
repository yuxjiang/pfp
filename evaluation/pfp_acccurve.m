function [curve] = pfp_acccurve(pred, ref, varargin)
    %PFP_ACCCURVE Accuracy curve
    %
    % [curve] = PFP_ACCCURVE(pred, ref, varargin);
    %
    %   Returns the accuracy curve(s) of predictor(s).
    %
    % Note
    % ----
    % 'curve' specifies a function curve: acc(tau).
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
    % curve:    A k-by-2 matrix, which specifies a (tau, auc) curve.

    % check inputs {{{
    if nargin < 2
        error('pfp_acccurve:InputCount', 'Expected at least 2 inputs.');
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

    % calculation {{{
    if isempty(p.Results.tau)
        tau = unique(pred);
    else
        tau = p.Results.tau;
    end
    % append end-points
    tau = unique([reshape(tau, 1, []), 0, 1+eps]);
    k   = numel(tau);
    acc = zeros(k, 1);
    for i = 1:k
        P = (pred>=tau(i));
        acc(i) = mean(P==ref, 1);
    end
    curve = [reshape(tau, [], 1), acc];
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:21:19 PM E
