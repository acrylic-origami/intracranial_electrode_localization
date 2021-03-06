classdef GridController < handle
    %electrode.GridController
    %   Portions of this code 
    
    properties(Access = protected)
        grids = {}
        gui_controller
        figure_controller
    end
    
    methods(Access = public)
        function obj = GridController(gui_controller)
            obj.gui_controller = gui_controller;
        end
        function figure_controller = get_figure_controller(this)
            figure_controller = this.figure_controller;
        end
        % <<Canonical>>
        function dims = get_current_dims(this)
            % Canonical current dimension
            dims = this.grids{this.get_current_grid()}.dims;
        end
        function mark(this, centroid, C, enabled)
%             assert(~any(isnan(this.selected)),...
%                 'GridController::mark:BadMethodCallException',...
%                 'Attempted to mark with no marker selected');
            idx = this.get_current_grid();
            this.grids{idx}.mark(centroid, C, enabled);
            
            this.select_if_exists(C);
        end
        function grid = get_grid(this, idx)
            grid = this.grids{idx};
        end
        function marker = get_selected_marker(this)
            idx = this.get_current_grid();
            marker = this.grids{idx}.get_local_selected_marker();
        end
        function grids_skinned = get_grids(this)
            grids_skinned = cell(length(this.grids), 1);
            i = 1;
            for grid = this.grids
                grid_ = grid{1,1};
                markers = grid_.markers;
                markers_skinned = cell(size(grid_));
                for j = 1:size(markers, 1)
                    for k = 1:size(markers, 2)
                        marker_ = markers{j, k};
                        if ~isempty(marker_)
                            marker_skinned = struct(...
                                'centroid', marker_.centroid,...
                                'enabled', marker_.enabled...
                                );
                            markers_skinned{j, k} = marker_skinned;
                        end
                    end
                end
                grid_skinned = electrode.SkinnedGrid(...
                        grid_.name,...
                        grid_.dims,...
                        markers_skinned...
                );
                grids_skinned{i} = grid_skinned;
                i = i+1;
            end
        end
        % Mutators
        function add_empty_grid(this, name, width, height)
%             this.unselect_last_selected();
            this.grids{length(this.grids) + 1} = electrode.Grid(name, width, height);
        end
        function add_grids(this, grids)
            this.grids = horzcat(this.grids, grids);
        end
        function update_grid_dims(this, dims)
            idx = this.get_current_grid();
            this.grids{idx}.dims = dims;
        end
        function update_grid_name(this, new_name)
            idx = this.get_current_grid();
            this.grids{idx}.name = new_name;
        end
        % <<Canonical>>
        function num = get_num_grids(this)
            num = length(this.grids);
        end
        function delete_grid(this, idx)
            if 1 <= idx && idx <= length(this.grids)
                this.grids{idx}.unmark_all();
                this.grids(idx) = []; % shift out of cell array
            end
        end
%         function unmark_current(this)
%             idx = this.get_current_grid();
%             if ~any(isnan(this.selected)) % &&...
%                % ~isempty()
%                 this.gui_controller.unmark(this.selected);
%                 this.grids{idx}.unmark(this.selected);
%             end
%         end
        function exists = unmark_if_exists(this, C)
            % for model consistency, MUST be called from GUIController
            exists = false;
            
            dims = this.get_current_dims();
            idx = this.get_current_grid();
            if all(1 <= C & C <= dims)
                exists = this.grids{idx}.has_marker(C); % existence, not enabled
                if this.grids{idx}.has_enabled_marker(C)
                    this.grids{idx}.unmark(C);
                end
            end
        end
        function exists = select_if_exists(this, C)
            % for model consistency, MUST be called from GUIController
            exists = false;
            
            dims = this.get_current_dims();
            idx = this.get_current_grid();
            if all(1 <= C & C <= dims)
                this.unselect_last_selected();
                if this.grids{idx}.has_enabled_marker(C)
                    this.grids{idx}.select(C);
                    
                    exists = true;
                end
                this.grids{idx}.selected = C;
            end
        end
        function maybe = in_range(this, C)
            idx = this.get_current_grid();
            maybe = all(1 <= C & C <= this.grids{idx}.dims);
        end
        function unselect_last_selected(this)
            idx = this.get_current_grid();
            selected = this.grids{idx}.unselect_local_selected();
            this.gui_controller.unselect(selected); % eh.
        end
        function toggle_selected(this, v)
            idx = this.get_current_grid();
            selected = this.grids{idx}.get_local_selected();
            this.gui_controller.unmark(selected); % ehhhhhh
            this.grids{idx}.toggle_local_selected(v);
        end
    end
    methods(Access = protected)
        function idx = get_current_grid(this)
            idx = this.gui_controller.get_current_grid();
        end
        function color = next_color(varargin)
            color = [ 0.8500    0.3250    0.0980 ]; % burnt orange
        end
    end
    methods(Access = protected, Static)
    end
end