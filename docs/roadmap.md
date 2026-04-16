# GetXDrop Roadmap

## Service Roadmap

### Phase 0: Problem Validation
- Position GetXDrop as a migration workbench, not a one-click converter.
- Validate that audit output helps legacy Flutter teams decide where to start.

### Phase 1: Audit MVP
- Deliver `doctor`, `audit`, and `report`.
- Generate markdown and JSON reports with risk and ordering guidance.

### Phase 2: Guided Planning
- Add deeper route and network inventory.
- Add controller complexity scoring and config support.

### Phase 3: Scaffold Assistant
- Generate target architecture skeletons for GoRouter, Dio, and Riverpod.

### Phase 4: Safe Apply Beta
- Add low-risk rewrites with dry-run-first behavior.

### Phase 5: Team Adoption
- Stabilize machine-readable outputs and CI integration.

### Phase 6: Optional Product Expansion
- Consider richer report UX only after the CLI workflow is stable.

## Development Roadmap

### Phase A: Foundation
- Workspace bootstrap with Melos and package boundaries.
- Preserve the sample GetX app as an integration fixture.

### Phase B: Analysis Core
- Build normalized models, AST visitors, and fallback scanners.

### Phase C: Report Core
- Render markdown and JSON reports from normalized inventory.

### Phase D: CLI MVP
- Implement `doctor`, `audit`, and `report`.

### Phase E: Validation and Docs
- Lock fixture expectations with integration tests and usage docs.

### Phase F: Scaffold Prep
- Reserve interfaces for future scaffold generation.

### Phase G: Safe Apply Prep
- Reserve codemod planning types and safety contracts.
