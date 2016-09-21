function [oa] = pfp_oacat(oa1, oa2)
    %PFP_OACAT Ontology concatenation
    %
    % [oa] = PFP_OACAT(oa1, oa2);
    %
    %   Concatenates two ontology annotation structures.
    %
    % Note
    % ----
    % The two structures that are to be concatenated should have two distinct
    % ontologies (with no overlapping terms).
    %
    % Input
    % -----
    % [struct]
    % oa1:  The first ontology annotation structure. See pfp_oabuild.m
    %
    % [struct]
    % oa2:  The second ontology annotation structure.
    %
    % Output
    % ------
    % [struct]
    % oa:   The concatenated ontology annotation structure.
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_oacat:InputCount', 'Expected 2 inputs.');
    end

    % oa1
    validateattributes(oa1, {'struct'}, {'nonempty'}, '', 'oa1', 1);

    % oa2
    validateattributes(oa2, {'struct'}, {'nonempty'}, '', 'oa2', 2);

    if ~isempty(intersect({oa1.ontology.term.id}, {oa2.ontology.term.id}))
        error('pfp_oacat:InputErr', 'Two ontologies must be different.');
    end
    % }}}

    % concatenate two ontologies {{{
    oa.object = intersect(oa1.object, oa2.object);
    [~, index1] = ismember(oa.object, oa1.object);
    [~, index2] = ismember(oa.object, oa2.object);

    oa.ontology.term = [oa1.ontology.term; oa2.ontology.term];
    n1 = numel(oa1.ontology.term);
    n2 = numel(oa2.ontology.term);
    n  = n1 + n2;

    oa.ontology.DAG = sparse(n, n);
    oa.ontology.DAG(1:n1, 1:n1) = oa1.ontology.DAG;
    oa.ontology.DAG((n1+1):end, (n1+1):end) = oa2.ontology.DAG;
    oa.ontology.ont_type = 'concatenated ontology';
    oa.ontology.date = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}

    % concatenate annotations {{{
    oa.annotation = [oa1.annotation(index1, :), oa2.annotation(index2, :)];
    oa.date       = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:04:22 PM E
