module Rubyplot
  module Artist
    module Plot
      class MultiStackedBar < Artist::Plot::Base
        def initialize(*args, stacked_bars:)
          super(args[0])
          @stacked_bars = stacked_bars
          @x_min = @stacked_bars.map(&:x_min).min
          @y_min = @stacked_bars.map(&:y_min).min
          @x_max = @stacked_bars.map(&:x_max).max
          @y_max = @stacked_bars.
            map { |s| s.y_values }.transpose.
            map { |a| a.inject(:+) }.max
          reset_axes_ranges
          configure_plot_geometry_data
  #        configure_x_ticks
        end

        def draw
          @stacked_bars.each(&:draw)
        end

        private

        def reset_axes_ranges
          @axes.y_axis.min_val = 0
          @axes.y_axis.max_val = @y_max
          @axes.x_axis.min_val = 0
        end

        def configure_plot_geometry_data
          @num_max_slots = @stacked_bars.map(&:num_bars).max
          @max_slot_width = (@axes.x_axis.max_val - @axes.x_axis.min_val) / @num_max_slots.to_f
          @spacing_ratio = @stacked_bars[0].spacing_ratio
          @padding = @spacing_ratio * @max_slot_width
          @max_bars_width = @max_slot_width - @padding
          @num_max_stacks = @stacked_bars.size
          @stacked_bars.each_with_index do |bar, index|
            set_bar_dims bar, index
          end
        end

        # FIXME: make backend agnostic.
        def configure_x_ticks
#          @axes.num_x_ticks = @num_max_slots
          labels = @axes.x_ticks || Array.new(@num_max_slots, &:to_s)
 #         labels = labels[0...@axes.num_x_ticks] if labels.size != @axes.num_x_ticks
          @axes.x_ticks = labels.map.with_index do |label, i|
            Rubyplot::Artist::XTick.new(
              @axes,
              abs_x: @axes.abs_x + @axes.left_margin + i * @max_slot_width + @max_slot_width / 2,
              abs_y: @axes.origin[1],
              label: label
            )
          end
        end

        def set_bar_dims bar, plot_index
          bar.bar_width = @max_bars_width
          plots_below = @stacked_bars[0...plot_index]
          bar.num_bars.times do |i|
            pedestal_height = plots_below.map { |p| p.y_values[i] }.inject(:+) || 0
            bar.abs_x_left[i] = @x_min  + i * @max_slot_width + @padding / 2
            bar.abs_y_left[i] = @axes.y_axis.min_val + pedestal_height
          end
        end
      end # class StackedBar
    end # module Plot
  end # module Artist
end # module Rubyplot
