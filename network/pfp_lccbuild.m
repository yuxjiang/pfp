function [net] = pfp_lccbuild(ifile)
    %PFP_LCCBUILD Largest connected component build
    %
    % [net] = PFP_LCCBUILD(ifile);
    %
    %   Builds a network structure by keeping only its largest connected
    %   component.
    %
    % Input
    % -----
    % [char]
    % ifile:    The edge data file. this function assumes that each line of the
    %           file contains three columns (separated by tab)
    %           <src> <dst> <edge weight>
    %           Note: the order of "src" and "dst" doesn't matter.
    %
    % Output
    % ------
    % [struct]
    % net:  The resulting network structure.
    %       .object [cell]   A n-by-1 cell array of (char) object ID list.
    %       .ADJ    [double] A n-by-n (sparse) adjacency matrix.
    %
    % Dependency
    % ----------
    % [>] Bioinformatics:graphconncomp

    % check inputs {{{
    if nargin ~= 1
        error('pfp_lccbuild:InputCount', 'Expected 1 input.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fid = fopen(ifile, 'r');
    if fid == -1
        error('pfp_lccbuild:FileErr', 'Cannot open the file [%s].', ifile);
    end
    data = textscan(fid, '%s%s%f', 'Delimiter', '\t');
    fclose(fid);
    % }}}

    % building {{{
    obj_list = union(data{1}, data{2});

    src = data{1};
    dst = data{2};
    weight = data{3};

    clear data

    [~, index_src] = ismember(src, obj_list);
    [~, index_dst] = ismember(dst, obj_list);

    % remove self connections
    self_conn = index_src == index_dst;
    index_src(self_conn) = [];
    index_dst(self_conn) = [];
    weight(self_conn)  = [];

    ADJ = sparse(index_src, index_dst, weight, numel(obj_list), numel(obj_list));
    ADJ = double(ADJ + ADJ' ~= 0);

    [s, c] = graphconncomp(ADJ);

    in_lcc = (c == mode(c));
    net.object = obj_list(in_lcc);
    net.ADJ = ADJ(in_lcc, in_lcc);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:15:32 PM E
