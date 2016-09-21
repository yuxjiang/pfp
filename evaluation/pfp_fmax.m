function [fmax, point, t]  = pfp_fmax(pred, ref, tau, beta)
    %PFP_FMAX F-measure maximum
    %
    % [fmax, point, t] = PFP_FMAX(pred, ref, tau);
    %
    %   Returns the maximum F_{1}-measure.
    %
    % [fmax, point, t] = PFP_FMAX(pred, ref, tau, beta);
    %
    %   Returns the maximum F_{beta}-measure.
    %
    % Input
    % -----
    % [double]
    % pred: An n-by-m predictions from m predictors, predicted scores must be
    %       within [0, 1].
    %
    % [logical]
    % ref:  An n-by-1 binary reference label corresponding to each term.
    %
    % [double]
    % tau:  A 1-by-k vector of thresholds.
    %
    % (optional)
    % [double]
    % beta: The beta of F_{beta}-measure.
    %       default: 1
    %
    % Output
    % ------
    % [double or cell]
    % fmax:     An 1-by-m cell of the minimum semantic distance. It returns a
    %           scalar if m = 1.
    %
    % [double or cell]
    % point:    Corresponding (pr, rc) that produces 'fmax'. It returns a 1-by-2
    %           double array if m = 1.
    %
    % [double or cell]
    % t:        The best corresponding threshold. Note that for m = 1, this
    %           function simply returns a tuple of plain data, instead of a
    %           tuple of 1-by-1 cells.
    %
    % Dependency
    % ----------
    % [>] pfp_prcurve.m
    % [>] pfp_fmaxc.m

    % check inputs {{{
    if nargin < 3 || nargin > 4
        error('pfp_fmax:InputCount', 'Expected 3 or 4 inputs.');
    end

    if nargin == 3
        beta = 1;
    end
    
    % pred
    validateattributes(pred, {'double'}, {'nonempty', '>=', 0, '<=', 1}, '', 'pred', 1);
    [n, m] = size(pred);

    % ref
    validateattributes(ref, {'logical'}, {'nrows', n, 'ncols', 1}, '', 'ref', 2);

    % tau
    validateattributes(tau, {'double'}, {'nonempty', '>=', 0, '<=', 1}, '', 'tau', 3);

    % beta
    validateattributes(beta, {'double'}, {'>', 0}, '', 'beta', 4);
    % }}}

    % calculate the precision-recall curve {{{
    curve = pfp_prcurve(pred, ref, tau);

    % check result
    if isempty(curve)
        fmax = NaN; point = []; t = NaN;
        return;
    end

    % calculate the fmax
    if ~iscell(curve)
        [fmax, point, t] = pfp_fmaxc(curve, tau, beta);
    else
        m = numel(curve);
        fmax = cell(1, m);
        point = cell(1, m);
        t = cell(1, m);
        for i = 1 : m
            [fmax{i}, point{i}, t{i}] = pfp_fmaxc(curve{i}, tau, beta);
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:12:37 PM E
