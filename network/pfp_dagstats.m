function [info] = pfp_dagstats(dag)
    %PFP_DAGSTATS
    %
    %   [info] = PFP_DAGSTATS(dag);
    %
    %       Returns an information structure that contains the information of a
    %       given DAG.
    %
    % Input
    % -----
    % [logical, sparse]
    % dag:  The DAG structure, see pfp_loaddag.m.
    %
    % Output
    % ------
    % [struct]
    % info: The information structure:
    %       .n      the number of vertices
    %       .e      the number of edges
    %       .mp     the number of multiparent vertices
    %       .mc     the number of multichild vertices
    %       .d      the maximum depth
    %               (depth: the length of the shortest path to the root)
    %       .l      the maximum level
    %               (level: the length of the longest path to the root)
    %
    % Dependency
    % ----------
    % [>] pfp_depth.m
    % [>] pfp_level.m

    % check inputs {{{
    if nargin ~= 1
        error('pfp_dagstats:InputCount', 'Expected 1 input.');
    end

    % dag
    validateattributes(dag, {'logical'}, {'nonempty', 'square'}, '', 'dag', 1);
    % }}}

    % get info {{{
    info.n     = size(dag, 1);
    info.e     = full(sum(dag(:)));
    info.mp    = full(sum(sum(dag) > 1));
    info.mc    = full(sum(sum(dag, 2) > 1));

    % make a virtual "ontology" structure
    ont.term = 1:info.n;
    ont.DAG  = dag;
    info.d   = pfp_depth(ont);
    info.l   = pfp_level(ont);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 11 Oct 2017 09:32:51 AM E
