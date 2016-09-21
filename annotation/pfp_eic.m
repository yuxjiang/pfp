function [eic] = pfp_eic(A)
    %PFP_EIC Estimated information content
    %
    % [eic] = PFP_EIC(A);
    %
    %   Estimates the information content for each term in the ontology.
    %
    % Definition
    % ----------
    % Information content (empirical):
    % ic(t) = -log P(t) = -log (n(t) / n(r))
    % where n(t) is the # of annotations of term 't' and n(r) is that of the
    % root term. Note that ic(t) for those unannotated terms is redefined to
    % zero.
    %
    % Input
    % -----
    % [logical]
    % A:    A n-by-m logical annotation matrix, which is assumed to be
    %       consistent. A(i, j) = true indicates object i is annotated to have
    %       term j.
    %
    % Output
    % ------
    % [double]
    % eic:  1-by-m, an array of estimated information content.
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_eic:InputCount', 'Expected 1 input.');
    end

    % A
    validateattributes(A, {'logical'}, {'nonempty'}, '', 'A', 1);
    % }}}

    % compute information content for each term {{{
    counts = sum(A, 1);
    eic    = - full(log(counts/max(counts)));
    eic(isinf(eic)) = 0;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:03:08 PM E
