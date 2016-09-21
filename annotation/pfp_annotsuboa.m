function [oa] = pfp_annotsuboa(oa)
    %PFP_ANNOTSUBOA Annotated sub-ontology annotation
    %
    % [oa] = PFP_ANNOTSUBOA(oa);
    %
    %   Returns the annotated sub-ontology annotation structure.
    %
    % Input
    % -----
    % [struct]
    % oa:   The ontology annotation structure. See pfp_oabuild.m.
    %
    % Output
    % ------
    % [struct]
    % oa:   The deflated ontology annotation structure.
    %
    % See Also
    % --------
    % [>] pfp_oabuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_annotsuboa:InputCount', 'Expected 1 input.');
    end

    % oa
    validateattributes(oa, {'struct'}, {'nonempty'}, '', 'oa', 1);
    % }}}

    % prepare for the output {{{
    has_annot = any(oa.annotation, 1);

    oa.ontology.term = oa.ontology.term(has_annot);
    oa.ontology.DAG  = oa.ontology.DAG(has_annot, has_annot);
    oa.annotation    = oa.annotation(:, has_annot);
    oa.date          = datestr(now, 'mm/dd/yyyy HH:MM');
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:01:22 PM E
