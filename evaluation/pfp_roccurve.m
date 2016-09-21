function [curve] = pfp_roccurve(pred, ref, varargin)
    %PFP_ROCCURVE Receiver operating characteristic curve
    %
    % [curve] = PFP_ROCCURVE(pred, ref, varargin);
    %
    %   Returns the ROC curves of each predicions.
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
    % curve:    A k-by-2 matrix, which specifies a (FPR, TPR) curve.

    % check inputs {{{
    if nargin < 2
        error('pfp_roccurve:InputCount', 'Expected at least 2 inputs.');
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

    % get curve {{{
    if isempty(p.Results.tau)
        tau = unique(pred);
    else
        tau = p.Results.tau;
    end
    % append end-points
    tau = unique([reshape(tau, 1, []), 0, 1+eps]);
    curve = loc_curve_from_tau(pred, ref, tau);
    % }}}
end

% function: loc_curve_from_tau {{{
function [curve] = loc_curve_from_tau(pred, ref, tau)
    k = numel(tau);

    % calculate confusion matrix for many thresholds
    N  = ~ref;
    nT = sum(ref);
    nN = sum(N);

    tpr = zeros(k, 1); % true positive rate (sensitivity)
    fpr = zeros(k, 1); % false positive rate (1-specificity)
    for i = 1 : k
        P = (pred >= tau(i));

        % determine elements of the confusion matrix
        TP = sum(P & ref);
        FN = sum(P & N);

        % calculate sensitivity and 1 - specificity
        tpr(i, :) = TP ./ nT;
        fpr(i, :) = FN ./ nN;
    end
    curve = flipud([fpr, tpr]);
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:39:17 PM E
