function [ont] = pfp_ontintersect(ont1, ont2)
    %PFP_ONTINTERSECT Ontology intersection
    %
    % [ont] = PFP_ONTINTERSECT(ont1, ont2);
    %
    %   Returns the intersection of two ontologies.
    %
    % Note
    % ----
    % This function assumes terms can be added/removed to/from the ontology
    % along the time, however, adding/removing edges is not allows.
    %
    % Input
    % -----
    % [struct]
    % ont1: The ontology structure 1. See pfp_ontbuild.m
    %
    % [struct]
    % ont2: The ontology structure 2.
    %
    % Output
    % ------
    % [struct]
    % ont:  The intersection of the two ontology.
    %
    % Dependency
    % ----------
    % [>] pfp_subont.m
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_ontintersect:InputCount', 'Expected 2 inputs.');
    end

    % ont1
    validateattributes(ont1, {'struct'}, {'nonempty'}, '', 'ont1', 1);
    % 

    % ont2
    validateattributes(ont2, {'struct'}, {'nonempty'}, '', 'ont2', 2);
    % }}}

    % get intersection {{{
    [term_id, index1, ~] = intersect({ont1.term.id}, {ont2.term.id});
    ont = pfp_subont(ont1, ont1.term(index1));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:15:35 PM E
