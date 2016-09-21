function [acc, point, t] = pfp_accc(curve)
    %PFP_ACCC Accuracy (from) curve
    %
    % [acc, point, t] = PFP_ACCC(curve);
    %
    %   Returns the maximum accuracy of the curve.
    %
    % Input
    % -----
    % [double]
    % curve:    An k-by-2  matrix (i.e. a curve)
    %
    % Output
    % ------
    % [double]
    % acc:      The maximum accuracy.
    %
    % [double]
    % point:    The corresponding (tau, auc) which yields 'acc'.
    %
    % [double]
    % t:        The best corresponding threshold.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_accc:InputCount', 'Expected 1 input.');
    end

    % curve
    validateattributes(curve, {'double'}, {'ncols', 2}, '', 'curve', 1);
    % }}}

    % calculation {{{
    if isempty(curve)
        acc = NaN; point = []; t = NaN;
        return;
    end
    [acc, index] = max(curve(:, 2));
    point = curve(index, :);
    t = curve(index, 1);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:20:51 PM E
