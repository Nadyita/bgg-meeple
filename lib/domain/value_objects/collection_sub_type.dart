/// Collection sub-types that can be used for filtering.
///
/// These map to the BGG collection flags stored on [CollectionItem].
enum CollectionSubType {
  owned,
  preordered,
  wishlisted,
  wantToPlay,
  wantToBuy,
  previouslyOwned,
  played,
  rated,
  forTrade,
  wantInTrade,
  hasComment,
}
