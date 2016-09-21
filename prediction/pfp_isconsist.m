function [consist] = pfp_isconsist(pred)
    %PFP_ISCONSIST Is consistent
    %
    % [consist] = PFP_ISCONSIST(pred);
    %
    %   Tests if a prediction is consistent.
    %
    % Input
    % -----
    % [sturct]
    % pred: The predicted ontology annotation structure.
    %
    % Output
    % ------
    % [logical]
    % consist:  Must be either true or false.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_isconsist:InputCount', 'Expected 1 input.');
    end

    % pred
    validateattributes(pred, {'struct'}, {'nonempty'}, '', 'pred', 1);
    % }}}

    % check consistency {{{
    consist = true;
    n = numel(pred.ontology.term);
    for i = 1 : n
        p = find(pred.ontology.DAG(i, :) ~= 0); % parent terms
        if isempty(p), continue; end
        if any(any(bsxfun(@gt, pred.score(:, i), pred.score(:, p)), 2))
            consist = false;
            return;
        end
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 12:47:50 PM E
