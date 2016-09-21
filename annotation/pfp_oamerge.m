function [oa] = pfp_oamerge(oa1, oa2)
    %PFP_OAMERGE Ontology annotation merge
    %
    % [oa] = PFP_OAMERGE(oa1, oa2);
    %
    %   Merges two ontology annotation structures.
    %
    % Note
    % ----
    % The two ontologies to be merged must have the same structure.
    %
    % Input
    % -----
    % [struct]
    % oa1:  The 1st ontology annotation structure. See pfp_oabuild.m
    %
    % [struct]
    % oa2:  The 2nd ontology annotation structure.
    %
    % Output
    % ------
    % [struct]
    % oa:   The merged ontology annotation structure.
    %
    % Dependency
    % ----------
    % [>] pfp_sameont.m
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_oamerge:InputCount', 'Expected 2 inputs.');
    end

    % oa1
    validateattributes(oa1, {'struct'}, {'nonempty'}, '', 'oa1', 1);

    % oa2
    validateattributes(oa2, {'struct'}, {'nonempty'}, '', 'oa2', 2);
    [match, msg] = pfp_sameont(oa1.ontology, oa2.ontology);
    if ~match
        error('pfp_oamerge:OntMissMatch', msg);
    end
    % }}}

    % merge {{{
    oa.object     = union(oa1.object, oa2.object);
    oa.ontology   = oa1.ontology;
    oa.annotation = logical(sparse(numel(oa.object), numel(oa.ontology.term)));

    [~, index1] = ismember(oa1.object, oa.object);
    [~, index2] = ismember(oa2.object, oa.object);

    oa.annotation(index1, :) = oa1.annotation;
    oa.annotation(index2, :) = oa.annotation(index2, :) | oa2.annotation;
    oa.date                  = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:04:52 PM E
