function [term, idx] = pfp_lookforterm(ont, name)
    %PFP_LOOKFORTERM Look for term
    %
    % [term, idx] = PFP_LOOKFORTERM(ont, name);
    %
    %   Returns the ID and its index of a given name.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % [char]
    % name: The name of a term
    %
    % Output
    % ------
    % [char]
    % term: The top-matched term ID.
    %
    % [double]
    % idx:  The index of the found term. NaN if not found.
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_lookforterm:InputCount', 'Expected 2 inputs.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);

    % name
    validateattributes(name, {'char'}, {'nonempty'}, '', 'name', 2);
    % }}}

    % find "exact" match {{{
    idx = find(strcmpi({ont.term.name}, name));
    if ~isempty(idx)
        term = ont.term(idx(1)).id; % only return the 1st one
    else
        error('pfp_lookforterm:InvalidName', 'Invalid term name.');
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:13:13 PM E
