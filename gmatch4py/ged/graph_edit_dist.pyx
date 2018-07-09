# -*- coding: UTF-8 -*-

import sys

import networkx as nx
import numpy as np
cimport numpy as np
from .abstract_graph_edit_dist cimport AbstractGraphEditDistance
from ..base cimport intersection


cdef class GraphEditDistance(AbstractGraphEditDistance):

    def __init__(self,node_del,node_ins,edge_del,edge_ins):
        AbstractGraphEditDistance.__init__(self,node_del,node_ins,edge_del,edge_ins)

    cpdef double substitute_cost(self, node1, node2, G, H):
        return self.relabel_cost(node1, node2, G, H)

    def relabel_cost(self, node1, node2, G, H):
        if node1 != node2:
            R = nx.create_empty_copy(G)
            R.add_edges_from(G.edges(node1,data=True))
            nx.relabel_nodes(R,{node1:node2},copy=False)

            R2 = nx.create_empty_copy(H)
            R2.add_edges_from(H.edges(node2,data=True))

            return abs(R2.number_of_edges()-intersection(R,R2).number_of_edges())
        else:
            return self.node_ins+self.node_del

    cdef double delete_cost(self, int i, int j, nodesG, G):
        if i == j:
            return self.node_del+(G.degree(nodesG[i])*self.edge_del) # Deleting a node implicate to delete in and out edges
        return sys.maxsize

    cdef double insert_cost(self, int i, int j, nodesH, H):
        if i == j:
            deg=H.degree(nodesH[j])
            if isinstance(deg,dict):deg=0
            return self.node_ins+(deg*self.edge_ins)
        else:
            return sys.maxsize