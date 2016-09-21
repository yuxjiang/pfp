function [c] = pfp_layercounts(ont)
    %PFP_LAYERCOUNTS Layer counts
    %
    % [c] = PFP_LAYERCOUNTS(ont);
    %
    %   Counts how many terms are there in each layer of the ontology.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % Output
    % ------
    % [double]
    % c:    A l-dimensional vector of which each entry being the counts.
    %
    % Dependency
    % ----------
    % [>] pfp_depth.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_layercounts:InputCount', 'Expected 1 input.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);
    % }}}

    % counting {{{
    max_depth = pfp_depth(ont);
    depths    = pfp_depth(ont, {ont.term.id});

    c = zeros(1, max_depth);
    for i = 1 : max_depth
        c(i) = sum(depths == i);
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 01:12:53 PM E
