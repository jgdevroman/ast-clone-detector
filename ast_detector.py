import javalang
import os
import hashlib

class CloneDetector:
    def __init__(self):
        self.tree_hashes = {}
        self.clones = []
        self.mass_threshold = 5  # Minimum number of nodes to consider a subtree
        self.similarity_threshold = 0.9  # Similarity threshold for near-miss clones
        self.sequence_length_threshold = 3  # Minimum length of sequence to consider

    def visit(self, node):
        if self.get_mass(node) >= self.mass_threshold:
            node_hash = self.hash_node(node)
            if node_hash in self.tree_hashes:
                if self.compare_trees(self.tree_hashes[node_hash], node) > self.similarity_threshold:
                    self.clones.append((self.tree_hashes[node_hash], node))
            else:
                self.tree_hashes[node_hash] = node
        for child in node.children:
            if isinstance(child, javalang.ast.Node):
                self.visit(child)

    def hash_node(self, node):
        """Hash a node based on its structure and content."""
        node_str = str(node)
        return hashlib.md5(node_str.encode()).hexdigest()

    def get_mass(self, node):
        """Calculate the mass (number of nodes) of a subtree."""
        return sum(1 for _ in self.walk(node))

    def walk(self, node):
        """Walk through all nodes in the subtree."""
        yield node
        for child in node.children:
            if isinstance(child, javalang.ast.Node):
                yield from self.walk(child)

    def compare_trees(self, node1, node2):
        """Compare two AST nodes for similarity."""
        node1_str = str(node1)
        node2_str = str(node2)
        shared = sum(1 for a, b in zip(node1_str, node2_str) if a == b)
        total = max(len(node1_str), len(node2_str))
        return shared / total

    def detect_sequences(self, tree):
        """Detect sequences of clones in the AST."""
        sequences = []
        for path, node in tree:
            if isinstance(node, (javalang.tree.CompilationUnit, javalang.tree.ClassDeclaration, javalang.tree.MethodDeclaration)):
                body = getattr(node, 'body', [])
                if len(body) >= self.sequence_length_threshold:
                    sequence_hashes = [self.hash_node(stmt) for stmt in body]
                    for i in range(len(sequence_hashes) - self.sequence_length_threshold + 1):
                        seq_hash = tuple(sequence_hashes[i:i + self.sequence_length_threshold])
                        if seq_hash in self.tree_hashes:
                            sequences.append((self.tree_hashes[seq_hash], body[i:i + self.sequence_length_threshold]))
                        else:
                            self.tree_hashes[seq_hash] = body[i:i + self.sequence_length_threshold]
        return sequences

    def detect_complex_clones(self):
        """Detect more complex near-miss clones by generalizing from existing clones."""
        clones_to_generalize = list(self.clones)
        while clones_to_generalize:
            original, clone = clones_to_generalize.pop()
            parent_original = getattr(original, 'parent', None)
            parent_clone = getattr(clone, 'parent', None)
            if parent_original and parent_clone:
                if self.compare_trees(parent_original, parent_clone) > self.similarity_threshold:
                    self.clones.append((parent_original, parent_clone))
                    clones_to_generalize.append((parent_original, parent_clone))

def detect_clones_in_project(project_path):
    detector = CloneDetector()
    for root, _, files in os.walk(project_path):
        for file in files:
            if file.endswith(".java"):
                file_path = os.path.join(root, file)
                with open(file_path, "r") as source:
                    tree = javalang.parse.parse(source.read())
                    detector.visit(tree)
    
    subtree_clones = detector.clones
    sequence_clones = detector.detect_sequences(tree)
    detector.detect_complex_clones()
    complex_clones = detector.clones
    
    return subtree_clones, sequence_clones, complex_clones

# Example usage
project_path = "projects/smallsql0.21_src"  # Replace with the path to your Java project
subtree_clones, sequence_clones, complex_clones = detect_clones_in_project(project_path)

print("Subtree Clones:")
for original, clone in subtree_clones:
    print(f"Original: {original}\nClone: {clone}\n")

print("Sequence Clones:")
for original_seq, clone_seq in sequence_clones:
    print(f"Original Sequence: {original_seq}\nClone Sequence: {clone_seq}\n")

print("Complex Clones:")
for original, clone in complex_clones:
    print(f"Original: {original}\nClone: {clone}\n")