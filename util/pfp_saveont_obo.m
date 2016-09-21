function [] = pfp_saveont_obo(ofile, ont)
    %PFP_SAVEONT_OBO Save ontology in OBO format
    %
    % [] = PFP_SAVEONT_OBO(ofile, ont);
    %
    %   Saves the ontology in OBO 1.2 format.
    %
    % Input
    % -----
    % [char]
    % ofile:    The output OBO file name.
    %
    % [struct]
    % ont:      The ontology structure. See pfp_ontbuild.m
    %
    % Output
    % ------
    % None.
    %
    % See Also
    % --------
    % [>] pfp_ontbuild.m
    % [>] pfp_loadont.m

    % check inputs {{{
    if nargin ~= 2
        error('pfp_saveont_obo:InputCount', 'Expected 2 inputs.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 1);
    fid = fopen(ofile, 'w');
    if fid == -1
        error('pfp_saveont_obo:FireErr', 'Cannot open the output file.');
    end

    % ont
    validateattributes(ont, {'struct'}, {'nonempty'}, '', 'ont', 2);
    % }}}

    % output header {{{
    fprintf(fid, 'format-version: 1.2\n');
    fprintf(fid, 'date: %s\n', datestr(now, 'dd:mm:yyyy HH:MM'));
    fprintf(fid, 'auto-generated-by: pfp_saveont_obo\n');
    fprintf(fid, '\n');
    % }}}

    % output terms {{{
    for i = 1 : numel(ont.term)
        fprintf(fid, '[Term]\n');
        fprintf(fid, 'id: %s\n', ont.term(i).id);
        fprintf(fid, 'name: %s\n', ont.term(i).name);
        dst_i = find(ont.DAG(i,:));
        rels = ont.rel_code(ont.DAG(i,dst_i));
        for j = 1 : numel(rels)
            if strcmp(rels{j}, 'is_a')
                fprintf(fid, 'is_a: %s ! %s\n', ont.term(dst_i(j)).id, ont.term(dst_i(j)).name);
            else
                fprintf(fid, 'relationship: %s %s ! %s\n', rels{j}, ont.term(dst_i(j)).id, ont.term(dst_i(j)).name);
            end
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:37:50 PM E
