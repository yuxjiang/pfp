function [bacc, point, t] = pfp_baccc(curve)
    %PFP_BACCC Balanced accuracy (from) curve
    %
    % [bacc, point, t] = PFP_BACCC(curve);
    %
    %   Returns the maximum balanced accuracy of the curve.
    %
    % Input
    % -----
    % [double]
    % curve:    An k-by-2  matrix (i.e. a curve)
    %
    % Output
    % ------
    % [double]
    % bacc:     The maximum balanced accuracy.
    %
    % [double]
    % point:    The corresponding (tau, bacc) which yields 'bacc'.
    %
    % [double]
    % t:        The best corresponding threshold.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_baccc:InputCount', 'Expected 1 input.');
    end

    % curve
    validateattributes(curve, {'double'}, {'ncols', 2}, '', 'curve', 1);
    % }}}

    % calculation {{{
    if isempty(curve)
        bacc = NaN; point = []; t = NaN;
        return;
    end
    [bacc, index] = max(curve(:, 2));
    point = curve(index, :);
    t = curve(index, 1);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:22:30 PM E
