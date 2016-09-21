function [curve] = pfp_rmcurve(pred, ref, eia, tau)
    %PFP_RMCURVE RU-MI curve
    %
    % [curve] = PFP_RMCURVE(pred, ref, eia, tau);
    %
    %   Calculates the ru-mi curve for predictors using the given thresholds.
    %
    % Input
    % -----
    % [double]
    % pred: An n-by-m predictions from m predictors, predicted scores must be
    %       within the range [0, 1].
    %
    % [logical]
    % ref:  An n-by-1 binary reference label corresponding to each term.
    %
    % [double]
    % eia:  An n-by-1 vector of estimated information accretion for each term.
    %
    % [double]
    % tau:  A 1-by-k vector of thresholds.
    %
    % Output
    % ------
    % [double or cell]
    % curve:    A 1-by-m cell array of curves, each of which contains a k-by-2
    %           matrix which specifies a ru-mi curve. Note that if m = 1,
    %           'curve' will simply be a k-by-2 matrix.

    % check inputs {{{
    if nargin ~= 4
        error('pfp_rmrcurve:InputCount', 'Expected 4 inputs.');
    end

    % pred
    validateattributes(pred, {'double'}, {'nonempty', '>=', 0, '<=', 1}, '', 'pred', 1);
    [n, m] = size(pred);

    % ref
    validateattributes(ref, {'logical'}, {'nrows', n, 'ncols', 1}, '', 'ref', 2);

    % eia
    validateattributes(eia, {'double'}, {'nrows', n, 'ncols', 1}, '', 'eia', 3);

    % tau
    validateattributes(tau, {'double'}, {'nonempty', '>=', 0, '<=', 1}, '', 'tau', 4);
    % }}}

    % calculation {{{
    k = numel(tau);
    nT = sum(ref); % the number of positives in the reference
    N = ~ref;

    ru = zeros(k, m);
    mi = zeros(k, m);
    for i = 1 : k
        P  = (pred >= tau(i));
        FN = bsxfun(@and, ~P, ref);
        FP = bsxfun(@and, P, N);

        mi(i, :) = sum(bsxfun(@times, FP, eia), 1);
        ru(i, :) = sum(bsxfun(@times, FN, eia), 1);
    end

    if m == 1
        curve = [ru, mi];
    else
        curve = cell(1, m);
        for i = 1 : m
            curve{i} = [ru(:,i), mi(:,i)];
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:06:44 PM E
