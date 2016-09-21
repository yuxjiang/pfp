function [sont] = pfp_ontsample(ont, counts)
    %PFP_ONTSAMPLE Ontology sample
    %
    % [sont] = PFP_ONTSAMPLE(ont, counts);
    %
    %   Samples the given ontology with specified number of terms per-layer.
    %
    % Input
    % -----
    % [struct]
    % ont:      The given ontology to be sampled from. See pfp_ontbuild.m
    %
    % [double]
    % counts:   The number of term required per-layer. E.g.
    %           [1, 3, 3, 5, 7, 3] would result in sampling 1 term at depth 1, 3
    %           terms at depth 2, 3 terms at depth 3 and so forth. Note that
    %           these "depth" refer to the depth of terms in the original 'ont',
    %           not the sampled one.
    %
    % Output
    % ------
    % sont: The sampled ontology structure.
    %
    % Dependency
    % ----------
    % [>] pfp_depth.m
    % [>] pfp_subont.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_ontsample:InputCount', 'Expected 2 inputs.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % counts
    validateattributes(counts, {'double'}, {'nonempty', 'integer', '>=', 0}, '', 'counts', 2);
    % }}}

    % sample terms {{{
    depths = pfp_depth(ont, {ont.term.id});
    L = numel(counts);
    selected = {};
    privileged = {};
    for i = 1 : L
        l = L + 1 - i; % sample the deepest layer first
        ns = counts(l) - numel(privileged); % numbers to sample
        if ns <= 0
            s = randsample(privileged, counts(l), false); % sample all from the privileged
        else
            exclude = union(privileged, selected);
            pool = setdiff({ont.term(depths == l).id}, exclude);
            s = [privileged, randsample(pool, ns, false)]; % sample the rest from the pool
        end
        selected = [selected, s];
        % update 'privileged' to be the immediate parent of the selected
        privileged = {};
        for j = 1 : numel(s)
            parent = pfp_parentterm(ont, s{j});
            privileged = setdiff(unique([privileged, {parent.id}]), selected);
        end
    end
    % }}}

    % make a subontology {{{
    sont = pfp_subont(ont, selected);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 01:16:09 PM E
