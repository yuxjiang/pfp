function [smin, point, t]  = pfp_smin(pred, ref, eia, tau, order)
    %PFP_SMIN Semantic distance mininum
    %
    % [smin, point, t] = PFP_SMIN(pred, ref, eia, tau);
    %
    %   Returns the minimum semantic (Euclidean) distance with a specific type
    %   of norm.
    %
    % [smin, point, t] = PFP_SMIN(pred, ref, eia, tau, order);
    %
    %   Returns the minimum semantic distance with a specific type of norm (with
    %   a given order).
    %
    % Note
    % ----
    % RU - remaining uncertainty.
    % MI - misinformation
    %
    % Input
    % -----
    % (required)
    % [double]
    % pred: An n-by-m predictions from m predictors, predicted scores must be
    %       within [0, 1].
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
    % (optional)
    % [double]
    % order:    Order of the norm
    %           default: 2 (Euclidean)
    %
    % Output
    % ------
    % [double or cell]
    % smin:     A 1-by-m cell of minimum semantic distance. It returns a scalar
    %           if m = 1.
    %
    % [double or cell]
    % point:    A 1-by-m cell of corresponding (RU, Mi) that produces 'smin'. It
    %           returns a 1-by-2 double array if m = 1.
    %
    % [double or cell]
    % t:        A 1-by-m cell of the best corresponding threshold. It returns a
    %           scalar if m = 1.
    %
    % Dependency
    % ----------
    % [>] pfp_rmcurve.m
    % [>] pfp_sminc.m

    % check inputs {{{
    if nargin < 4 || nargin > 5
        error('pfp_smin:InputCount', 'Expected 4 or 5 inputs.');
    end

    if nargin == 4
        order = 2;
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

    % order
    validateattributes(order, {'double'}, {'>', 0}, '', 'order', 5);
    % }}}

    % calculate the RU-MI curve {{{
    curve = pfp_rmcurve(pred, ref, eia, tau);

    % check result
    if isempty(curve)
        smin = NaN; point = []; t = NaN;
        return;
    end

    % calculate the smin
    if ~iscell(curve)
        [smin, point, t] = pfp_sminc(curve, tau, order);
    else
        m = numel(curve);
        smin = cell(1, m);
        point = cell(1, m);
        t = cell(1, m);
        for i = 1 : m
            [smin{i}, point{i}, t{i}] = pfp_sminc(curve{i}, tau, order);
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:11:03 PM E
