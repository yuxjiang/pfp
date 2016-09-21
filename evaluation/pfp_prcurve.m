function [curve] = pfp_prcurve(pred, ref, tau)
    %PFP_PRCURVE Precision-Recall curve
    %
    % [curve] = PFP_PRCURVE(pred, ref, tau);
    %
    %   Calculates the precision-recall curve for predictors using the given
    %   thresholds.
    %
    % Input
    % -----
    % [double]
    % pred: An n-by-m prediction matrix from m predictors. Predicted scores must
    %       be within the range [0, 1].
    %
    % [logical]
    % ref:  An n-by-1 binary vector of reference labels.
    %
    % [double]
    % tau:  A 1-by-k vector of thresholds.
    %
    % Output
    % ------
    % [cell]
    % curve:    A 1-by-m cell array of curves, each of which contains a k-by-2
    %           matrix which specifies a precision-recall curve. Note that if m
    %           = 1, 'curve' will simply be a k-by-2 matrix.

    % check inputs {{{
    if nargin n ~= 3
        error('pfp_prcurve:InputCount', 'Expected 3 inputs.');
    end

    % pred
    validateattributes(pred, {'double'}, {'nonempty', '>=', 0, '<=', 1}, '', 'pred', 1);
    [n, m] = size(pred);

    % ref
    validateattributes(ref, {'logical'}, {'nrows', n, 'ncols', 1}, '', 'ref', 2);

    % tau
    validateattributes(tau, {'double'}, {'nonempty', '>=', 0, '<=', 1}, '', 'tau', 3);
    % }}}

    % calculation {{{
    k = numel(tau);

    nT = sum(ref); % the number of positives in the reference

    pr = zeros(k, m);
    rc = zeros(k, m);
    for i = 1 : k
        P  = (pred >= tau(i));
        nP = sum(P, 1); % the number of each predicted positives

        nTP = sum(bsxfun(@and, P, ref), 1);
        pr(i, :) = nTP ./ nP;
        rc(i, :) = nTP ./ nT;
    end

    if m == 1
        curve = [pr, rc];
    else
        curve = cell(1, m);
        for i = 1 : m
            curve{i} = [pr(:, i), rc(:, i)];
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:38:36 PM E
