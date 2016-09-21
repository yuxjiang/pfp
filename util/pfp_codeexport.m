function [] = pfp_codeexport(edir, ldir, files)
    %PFP_CODEEXPORT Code export
    %
    % [] = PFP_CODEEXPORT(edir, ldir, files);
    %
    %   Exports source code, including 'files' and all their dependencies.
    %
    % Input
    % -----
    % [char]
    % edir:     The path to a (presumably empty) folder to export codes.
    %
    % [char]
    % ldir:     The path to a matlab library for searching.
    %           E.g.  ~/Library/libcb-MATLAB/
    %
    % [cell]
    % files:    A cell list of files (MATLAB scripts: *.m). Note that this
    %           script assumes all files should be inside the given library
    %           against which to search for.
    %
    % Output
    % ------
    % None.

    % check inputs {{{
    if nargin ~= 3
        error('pfp_codeexport:InputCount', 'Expected 3 inputs.');
    end

    % edir
    validateattributes(edir, {'char'}, {'nonempty'}, '', 'edir', 1);
    edir = regexprep([edir, '/'], '//', '/');
    if ~exist(edir, 'dir')
        mkdir(edir);
    end

    % ldir
    validateattributes(ldir, {'char'}, {'nonempty'}, '', 'ldir', 2);
    if ~exist(ldir, 'dir');
        error('pfp_codeexport:DirErr', 'libcb-MATLAB dir doesn''t exist.');
    end

    % files
    validateattributes(files, {'cell'}, {}, '', 'files', 3);
    % }}}

    % initialization {{{
    queue = reshape(files, [], 1);
    pool  = {}; % a pool of "path to source code files"
    n = 0;
    % }}}

    % recursively add dependencies {{{
    while ~isempty(queue)
        [file, queue] = loc_dequeue(queue);
        [status, result] = system(sprintf('find %s -name "%s"', ldir, file));

        % checking and parsing {{{
        if status ~= 0
            error('pfp_codeexport:FindErr', result);
        end

        hits = strsplit(result, '\n');
        hits(cellfun(@isempty, hits)) = [];
        if numel(hits) == 0
            error('pfp_codeexport:FileErr', 'Cannot Find file [%s].', file);
        end

        if numel(hits) > 1
            error('pfp_codeexport:FileErr', 'Found duplicated files [%s].', file);
        end

        if ismember(hits{1}, pool)
            continue;
        end
        % }}}

        % dump into the pool
        pool = [pool; hits];

        % enqueue dependencies
        [status, result] = system(sprintf('egrep "^\\s*%%\\s*\\[>\\]" %s', hits{1}));

        if status == 1 && isempty(result)
            % no dependency found
            continue;
        end

        if status ~= 0
            error('pfp_codeexport:EgrepErr', result);
        end

        deps = strsplit(result, '\n');
        for i = 1 : numel(deps)
            if ~isempty(deps{i})
                d = regexprep(deps{i}, '.*]\s*', '');
                if regexp(d, '.*\.m')
                    % enqueue
                    queue = [queue; {d}];
                end
            end
        end
    end
    unique(pool);
    % }}}

    % copy selected files to edir (export) {{{
    for i = 1 : numel(pool)
        system(sprintf('cp %s %s', pool{i}, edir));
    end
    % }}}
end

% function: loc_dequeue {{{
function [element, queue] = loc_dequeue(queue)
    element = queue{1};
    queue = queue(2 : end);
end
% }}}

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:27:30 PM E
