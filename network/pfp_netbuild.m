% [need to be tested]
function [net] = pfp_netbuild(ifile, list)
    %PFP_NETBUILD Network Builds
    %
    % [net] = PFP_NETBUILD(ifile);
    %
    %   Builds a network structure from file.
    %
    % [net] = PFP_NETBUILD(ifile, list);
    %
    %   Builds a network structure from file with specified nodes (objects).
    %
    % Note
    % ----
    % 1. The returning network is undirected.
    % 2. Self-loops are ignored.
    %
    % Input
    % -----
    % [char]
    % ifile:    The edge data file. this function assumes that each line of the
    %           file contains three columns (separated by tab)
    %           <src> <dst> <edge weight>
    %           Note: the order of "src" and "dst" doesn't matter.
    %
    % (optional)
    % [cell]
    % list: A cell array of (char) object ID list.
    %       Given 'list', the resulting network will be built using only these
    %       given nodes. An empty 'list' means to use all nodes in the data
    %       file.
    %       default: {}
    %
    % Output
    % ------
    % [struct]
    % net:  The resulting network structure.
    %       .object [cell]   A n-by-1 cell array of (char) object ID list.
    %       .ADJ    [double] A n-by-n (sparse) adjacency matrix.

    % check inputs {{{
    if nargin ~= 1 && nargin ~= 2
        error('pfp_netbuild:InputCount', 'Expected 1 or 2 inputs.');
    end

    if nargin == 1
        list = {};
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fid = fopen(ifile, 'r');
    if fid == -1
        error('pfp_netbuild:FileErr', 'Cannot open the file [%s].', ifile);
    end
    data = textscan(fid, '%s%s%f', 'Delimiter', '\t');
    fclose(fid);

    % list
    validateattributes(list, {'cell'}, {}, '', 'list', 2);
    if isempty(list)
        list = union(data{1}, data{2});
        found = true(1, numel(data{1})); % set all object as found
    else
        found1 = ismember(data{1}, list);
        found2 = ismember(data{2}, list);
        found = found1 & found2;
    end
    % }}}

    % map objects and scores/weights {{{
    src    = data{1}(found);
    dst    = data{2}(found);
    weight = data{3}(found);

    clear data

    [~, index_src] = ismember(src, list);
    [~, index_dst] = ismember(dst, list);
    % }}}

    % remove self connections {{{
    self_conn = (index_src == index_dst);
    index_src(self_conn) = [];
    index_dst(self_conn) = [];
    weight(self_conn)  = [];
    % }}}

    % build network {{{
    net.object = list;
    ADJ = sparse(index_src, index_dst, weight, numel(list), numel(list));
    % net.ADJ = double(ADJ + ADJ' ~= 0);
    net.ADJ = ADJ + ADJ';
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:16:39 PM E
