module Geometry
  class PointInPolygon < Struct.new(:point, :polygon)
    extend Memoist

    def inside?
      point_location == :inside
    end

    def outside?
      point_location == :outside
    end

    def on_the_boundary?
      point_location == :on_the_boundary
    end

    def point_location
      return :outside unless bounding_box.contains?(point)
      return :on_the_boundary if point_is_vertex? || point_on_edge?

      point_inside_polygon? ? :inside : :outside
    end

    delegate :vertices, :edges, :bounding_box, :to => :polygon
    memoize :point_location, :edges, :bounding_box

    private

    def point_is_vertex?
      vertices.any? { |vertex| vertex == point }
    end

    def point_on_edge?
      edges.any? { |edge| edge.contains_point?(point) }
    end

    def point_inside_polygon?
      # Algorithm source:
      # https://wrf.ecse.rpi.edu//Research/Short_Notes/pnpoly.html

      result = false

      vertices.each_with_index do |vertex, i|
        previous_vertex = vertices[i - 1] || vertex.last
        if ((vertex.y > point.y) != (previous_vertex.y > point.y)) &&
           (point.x < (previous_vertex.x - vertex.x) * (point.y - vertex.y) /
            (previous_vertex.y - vertex.y) + vertex.x)
          result = !result
        end
      end

      result
    end
  end
end
