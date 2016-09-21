function [auc] = pfp_aucc(curve)
    %PFP_AUCC AUC (from) curve
    %
    % [auc] = PFP_AUCC(curve);
    %
    %   Returns the AUC of a ROC curve.
    %
    % Input
    % -----
    % [double]
    % curve:    A k-by-2 matrix, (FPR, TPR), ROC curve.
    %
    % Output
    % ------
    % [double]
    % auc:  The resulting AUC.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_aucc:InputCount', 'Expected 1 input.');
    end

    % curve
    validateattributes(curve, {'double'}, {'>=', 0, '<=', 1}, '', 'curve', 1);
    % }}}

    % compute AUC {{{
    % enforce the start and ending point
    curve = [0, 0; curve; 1, 1];
    auc = trapz(curve(:, 1), curve(:, 2));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:21:49 PM E
