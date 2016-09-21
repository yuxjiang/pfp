function [bf] = pfp_brfactor(ont)
    %PFP_BRFACTOR Branching factor
    %
    % [bf] = PFP_BRFACTOR(ont);
    %
    %   Returns the "branching factor" of an ontology.
    %
    % Definition
    % ----------
    % Branching factor: The average number of immediate children over all internal
    % nodes.
    %
    % Input
    % -----
    % [struct]
    % ont:  The ontology structure. See pfp_ontbuild.m
    %
    % Output
    % ------
    % [double]
    % bf:   The branching factor.
    %
    % Dependency
    % ----------
    % [>] pfp_ontbuild.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_brfactor:InputCount', 'Expected 1 input.');
    end

    % check the 1st argumrnt 'ont'
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 1);
    % }}}

    % get branching factor {{{
    bf = full(mean(sum(ont.DAG(:, any(ont.DAG, 1)))));
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 01:11:12 PM E
