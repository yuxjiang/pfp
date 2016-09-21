function [match, msg] = pfp_sameont(ont1, ont2)
    %PFP_SAMEONT Same ontology
    %
    % [match, msg] = PFP_SAMEONT(ont1, ont2);
    %
    %   Checks if two ontology structures are the same.
    %
    % Note
    % ----
    % 1. This function only checks term ID but not term names.
    % 2. The 'rel_code' field of the two ontologies must match as well.
    %
    % Input
    % -----
    % [struct]
    % ont1: The 1st ontology structure. See pfp_ontbuild.m
    %
    % [struct]
    % ont2: The 2nd ontology structure.
    %
    % Output
    % ------
    % [logical]
    % match:  True or false.
    %
    % [char]
    % msg:    The message explains why two ontologies are not the same.
    %         It's set to be empty if the two matches.
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_sameont:InputCount', 'Expected 2 inputs.');
    end

    % ont1
    validateattributes(ont1, {'struct'}, {'nonempty'}, '', 'ont1', 1);

    % ont2
    validateattributes(ont2, {'struct'}, {'nonempty'}, '', 'ont2', 2);
    % }}}

    % pre-setting {{{
    match = false;
    msg    = '';
    % }}}

    % check terms {{{
    if numel(ont1.term) ~= numel(ont2.term)
        msg = 'number of terms are not the same.';
        return;
    end

    if ~all(strcmp({ont1.term.id}, {ont2.term.id}))
        msg = 'term ids are not the same.';
        return;
    end
    % }}}

    % check structure {{{
    if ~all(strcmp(ont1.rel_code, ont2.rel_code))
        msg = 'relation codes are not the same.';
        return;
    end

    if ~all(all(ont1.DAG == ont2.DAG))
        msg = 'two DAG structures are not the same.';
        return;
    end
    % }}}

    % passed all checks {{{
    match = true;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 01:16:50 PM E
