function [] = idmapping_s2p(ifile, mfile, ofile)
    %IDMAPPING_S2P ID mapping secondary to primary
    %
    % [] = IDMAPPING_S2P(ifile, mfile, ofile);
    %
    %   Maps UniProt accessions from secondary to primary in a annotation file.
    %
    % Note
    % ----
    % 1. The mapping file should contain all secondary accessions for a
    %    sequence.
    % 2. Any sequence that is not mapped (probably 'obsoleted' in UniProt) will
    %    be ignored i.e. won't appear in the resulting file.
    % 3. Once a 'demerge' event occurred to an accession A to B and C, i.e.
    %         A
    %        / \
    %       /   \
    %      v     v
    %      B     C
    %    Then there should be two corresponding lines in the mapping file:
    %    <primary> <secondary>
    %       B           A
    %       C           A
    %    Any annotations to A should be transferred to B and C, hence, an
    %    annotation entry in the input file, e.g.,
    %    A    GO:1234567  ...
    %    generates two copies of this entry in the output file:
    %    B    GO:1234567  ...
    %    C    GO:1234567  ...
    %
    % Input
    % -----
    % [char]
    % ifile:    The raw annotation file, delimited by 'tab', with the first
    %           column being protein accession number.
    %           <accession> ...
    %
    % [char]
    % mfile:    The accession mapping file, having pacc-sacc pairs as rows:
    %           <primary> <secondary (or primary)>
    %           Note: this mapping file can be built from UniProt format data
    %           file, see idmapping_build_ups.m (with the 1st column, UniProt
    %           ID, removed from that resulting file).
    %
    % [char]
    % ofile:    The output annotation file, have the same columns as the input
    %           file.
    %
    % Output
    % ------
    % None.
    %
    % See Also
    % --------
    % [>] idmapping_build_ups.m

    % check inputs {{{
    if nargin ~= 3
        error('idmapping_s2p:InputCount', 'Expected 3 inputs.');
    end

    % ifile
    validateattributes(ifile, {'char'}, {'nonempty'}, '', 'ifile', 1);
    fin = fopen(ifile, 'r');
    if fin == -1
        error('idmapping_s2p:FileErr', 'Cannot open the input file.');
    end

    % mfile
    validateattributes(mfile, {'char'}, {'nonempty'}, '', 'mfile', 2);
    fmap = fopen(mfile, 'r');
    if fmap == -1
        error('idmapping_s2p:FileErr', 'Cannot open the mapping file.');
    end

    % ofile
    validateattributes(ofile, {'char'}, {'nonempty'}, '', 'ofile', 3);
    fout = fopen(ofile, 'w');
    if fout == -1
        error('idmapping_s2p:FileErr', 'Cannot open the output file.');
    end
    % }}}

    % read the mapping file {{{
    % the first column is unused in this function
    mapping = textscan(fmap, '%s%s');
    fclose(fmap);
    % }}}

    % sort mapping on 'secondary' column {{{
    % required for handling 'demerge' event, see below
    [~, order] = sort(mapping{2});
    mapping{1} = mapping{1}(order);
    mapping{2} = mapping{2}(order);
    % }}}

    % read 1st input line to build 'fmt' for 'textscan' {{{
    line = fgetl(fin);
    fclose(fin);

    segments = strsplit(line, '\t');
    k = numel(segments);
    fmt = repmat('%s', 1, k);

    fin = fopen(ifile, 'r'); % re-open again
    % }}}

    % converting {{{
    bs = 1e5; % block size

    data = textscan(fin, fmt, bs);
    while ~isempty(data{1})
        [found, index] = ismember(data{1}, mapping{2});

        % ignore unmapped accessions
        batch = find(found);
        index = index(found);

        for i = 1 : numel(batch) % {{{
            batch_i = batch(i);

            % check for 'demerge' event
            % Note that Matlab 'ismember' only returns the index of the first matched entry
            % so we need to walk down to the sorted list 'mapping{2}'
            from = data{1}{batch_i};
            walking = index(i);
            step = 0;
            while walking + step <= numel(mapping{2}) && strcmp(from, mapping{2}{walking + step})
                % print out
                fprintf(fout, '%s', mapping{1}{walking + step});
                for j = 2 : k
                    fprintf(fout, '\t%s', data{j}{batch_i});
                end
                fprintf(fout, '\n');

                step = step + 1;
            end
        end % }}}

        data = textscan(fin, fmt, bs);
    end
    fclose(fin);
    fclose(fout);
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:19:16 PM E
