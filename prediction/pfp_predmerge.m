function [pred] = pfp_predmerge(pred1, pred2)
    %PFP_PREDMERGE Prediction merge
    %
    % [pred] = PFP_PREDMERGE(pred1, pred2);
    %
    %   Merges two prediction structures.
    %
    % Note
    % ----
    % 1. If two predictors have predictions on the same object (e.g. protein),
    %    this function returns the one with higher scores (term-wise)
    % 2. Merged scores will be propagated bottom-up to guarentee consistent
    %    predictions. (with the "maximum" scheme. See pfp_predprop.m for
    %    details)
    %
    % Input
    % -----
    % [struct]
    % pred1:    The 1st prediction structure.
    %
    % [struct]
    % pred2:    The 2nd prediction structure.
    %
    % Output
    % ------
    % [struct]
    % pred: The resulting merged structure.
    %
    % Dependency
    % ----------
    % [>] pfp_sameont.m
    % [>] pfp_predprop.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_predmerge:InputCount', 'Expected 2 inputs.');
    end

    % pred1
    validateattributes(pred1, {'struct'}, {'nonempty'}, '', 'pred1', 1);

    % pred2
    validateattributes(pred2, {'struct'}, {'nonempty'}, '', 'pred2', 2);
    [match, msg] = pfp_sameont(pred1.ontology, pred2.ontology);
    if ~match
        error('pfp_predmerge:OntMissMatch', msg);
    end
    % }}}

    % merging {{{
    % preparing fields
    pred.object   = union(pred1.object, pred2.object);
    pred.ontology = pred1.ontology;

    % align scores
    score1 = loc_align_score(pred1, pred.object);
    score2 = loc_align_score(pred2, pred.object);

    pred.score = bsxfun(@max, score1, score2);
    pred = pfp_predprop(pred, true, 'max');
    pred.date = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}
end

% function: loc_align_score {{{
function [score] = loc_align_score(pred, obj)
    % Make sure the all pred.object are presented in obj.
    n = numel(obj);
    m = numel(pred.ontology.term);
    [~, index] = ismember(pred.object, obj);
    score = sparse(n, m);
    score(index, :) = pred.score;
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 12:57:22 PM E
