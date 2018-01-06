function [dag] = pfp_loaddag(efile)
    %PFP_LOADDAG
    %
    %   [dag] = PFP_LOADDAG(efile);
    %
    %       Load a DAG from the edge file.
    %
    % Note
    % ----
    % This function simply concerns about the structure of the graph. Vertex ID
    % will be ignored, and it is important to notice that any singletons are
    % excluded.
    %
    % Input
    % -----
    % [char]
    % efile:    The edge file which specifies a DAG
    %           <source> <target>
    %           Note that the first header line is ignored.
    %
    % Output
    % ------
    % [logical, sparse]
    % dag:  The resulting DAG structure represented as an adjacency matrix.
    %       dag(i,j) = 1 indicates an edge from i to j.

    % check inputs {{{
    if nargin ~= 1
        error('pfp_loaddag:InputCount', 'Expected 1 input.');
    end

    % efile
    validateattributes(efile, {'char'}, {'nonempty'}, '', 'efile', 1);
    % }}}

    % read and build the dag {{{
    edges = textscan(fopen(efile, 'r'), '%s%s', 'HeaderLines', 1);

    vertices = union(edges{1}, edges{2});
    [~, sid] = ismember(edges{1}, vertices);
    [~, tid] = ismember(edges{2}, vertices);
    dag = sparse(sid, tid, ones(length(edges{1}), 1), numel(vertices), numel(vertices)) ~= 0;
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 11 Oct 2017 08:59:41 AM E
