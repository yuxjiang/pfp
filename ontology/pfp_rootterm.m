function [term, idx] = pfp_rootterm(ont)
    %PFP_ROOTTERM Root term(s) of an ontology
    %
    % [term, idx] = PFP_ROOTTERM(ont);
    %
    %   Returns the root term(s) and it's index of an ontology.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % Output
    % ------
    % [struct]
    % term: A structure array of root term(s).
    %
    % [double]
    % idx:  The index of root term.
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_rootterm:InputCount', 'Expected 1 input.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);
    % }}}

    % root term {{{
    isroot = ~any(ont.DAG ~= 0, 2);
    term   = ont.term(isroot);
    idx    = reshape(find(isroot), 1, []);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:16:38 PM E
