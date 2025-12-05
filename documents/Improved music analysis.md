# Improved music analysis

I want to design a model that creates vector embeddings for audio (specifically, songs) (variable length input stream) that capture the "feel" of the song. The goal of this is to improve a music player I've been working on for the past few years (<https://github.com/AnthonyMichaelTDM/mecomp>), and specifically the mecomp-analysis crate (which generates the feature vectors (embeddings) that are used to power MECOMPs recommendation features (that essentially boil down to nearest-neighbor search and clustering)).

The application already exists and is mature, all that this project entails is designing a model that can replace (or supplement) my current methods of generating features, and maybe designing platform to crowdsource annotations (which could be as complicated as a custom web-app, or as simple as a spreadsheet or google form, I don't care as long as it works).

The idea is similar to <https://lelele.io/thesis.pdf> (in fact, I plan to base our data collection off of section 3), but instead of training a distance metric (optimizing how features/embeddings are compared), I want to optimize how the features/embeddings themselves are generated.

The biggest turn off I imagine people will have with this project is that given what MECOMP is written in, the final model needs to be implemented in Rust for inference (training can be done in whatever as long as we can save it to a compatible format). Rust's DL ecosystem isn't as advanced as, say, Python, but there are some frameworks available:

- <https://github.com/Tracel-AI/burn>
- <https://github.com/huggingface/candle>

Anyway, I'm looking for 2-3 people with one or more of the following qualities:

- Experience with audio processing (bonus points if your experience was related to ML)
- Experience designing DL models that take variable-length input (e.g., video, text, or in this case audio) (so, basically, if you've designed an RNN or Transformer-based network)
- Interest in designing, deploying, and marketing a web survey to crowdsource annotations (see section 3 of: <https://lelele.io/thesis.pdf> (which, to be clear, was not written by me))
- The time to help curate a diverse dataset of audio samples, and help sort through user-submitted annotations

If you're interested or want to discuss the idea further, feel free to reach out on Piazza, over email (ar312@rice.edu), or on Discord (@tonydangermouse)

The rest of this document is just a mind dump of my idea(s), which I typed out on a road-trip.

## Idea

Use RNN with CNN head to generate embeddings (maybe supplement with my existing analysis features (like as the initial “hidden state” of the RNN))

## Methodology (dataset and validation (loss))

For validation: Evaluate with human created similarity triplets

- have people listen to snippets of 3 songs, and decide which two sound the most similar. If using a distance metric (L2) on models outputs yields a result that aligns with human decisions, the test passes, otherwise it fails
- This will be the loss function, but training should prioritize accuracy over loss in principle

By recruiting multiple human evaluators, listening to 10~20 second snippets, etc. I should be able to get tens of thousands of training and validation samples from my existing music library (which I could then augment with open source music datasets for even more training data)

- goal: multiple GB of training and validation data

## Methodology (making inference fast)

As for running it, the CNN encoder can be run in parallel on the song segments, then the outputs from each segment could be fed into the RNN head sequentially as they’re generated.

- parallelism for inference isn’t super important really, since many songs will be analyzed in parallel anyway. In fact, the max I might want to do is running the RNN head on the CNN encoder outputs on the current segment + the cnn on the next segment in parallel (so, 2 workers per song)

## Constraints / success criteria

The model needs to be small enough to have a negligible footprint on consumer hardware, ideally the weights should be less than 1-5Mb.

Needs to be small enough that inference over a collection of ~1000 songs (with standard duration of maybe 3-4minutes) can be completed in, say, 3 minutes on a somewhat modern laptop (framework 16).

For a maximum, the model must be redesigned if the time to analyze a given amount of music (measured by total duration) sequentially (that is, not running multiple songs at once) is longer than, say,  0.5% of that duration.

- if this threshold is exceeded, the model shouldn’t necessarily be abandoned, instead it could be distilled into a smaller model with a more simple architecture

## Comparison with state-of-the-art

That’s the idea, but why this instead of chopping the last layer off a standard audio classifier (like wav2vec)? Simple, those embeddings are fine for describing individual songs, but not how they sound compared to other songs, making those kinds of features not entirely suitable for use in music recommendation systems like that of MECOMP. Additionally, many FOSS methods for audio embeddings I’ve found work only on fixed sized input, and/or aren’t trained specifically for music, or are trained only for one specific genre of music. Songs have a lot of variation in their length, so those are also ruled out (though may still be useful as a basis for the CNN head, either directly or after being distilled into a smaller network)

This idea is similar, but significantly more advanced than what the Bliss-rs project hints at with training a mahablois distance evaluator with the song triples I described above (see <https://lelele.io/thesis.pdf>), in fact, by training the embedding generator we can bypass the need to train a distance evaluator entirely, since the weights bliss trains would be absorbed into the model

## Future work

Using a transformer (or other attention mechanism) for the head may prove beneficial since, like with words are in understanding the meaning of text, some sounds (or parts of a song) are more important than others in contributing to the feel of a song

## Design considerations (Open Questions / things to test)

Should the window (inputs to the CNN encoder) be a sliding window (segments slightly overlap with each other) or chunked (no overlap)?

- I suspect that sliding window will be beneficial for an RNN, however maybe chunked will be better for a transformer

What about songs with differing sample rates / number of samples?

- MECOMP-analysis (fork of bliss) already handles downsampling songs into a standard refresh rate and number of channels (16kHz mono, iirc)

What should the exact length of the window be?

- I think it should be a multiple of the length of cache lines for common CPUs, and end up being about 1 second in length
- The length of the song samples used for training and validation should be varied for robustness, but generally fall between 20.0-60.0x that of the window size (need not be an integer multiple, robustness against padding should be built during training).

What about songs that can’t be split evenly into that length?

- Windowing helps, can use the overlap to absorb the discrepancy
- Otherwise, zero-padding the start and end windows should be sufficient

Should song metadata (like artist, album, release year, or even whether the songs are in the same album) be considered?

- probably not by the model itself, there’s too much variation within songs by some artists, and even within many albums, for that to be a reliable metric

What should the actual inputs to the model be?

- either the raw audio samples, or
- Something like <https://en.wikipedia.org/wiki/Mel-frequency_cepstrum> components, or
- even the features currently generated and used by MECOMP-analysis (this would eliminate the need for a CNN encoder, and allow for a much much simpler model (on second thought, this might be good as the proof of concept since small models are easy to train)

Should an ensemble be used for the encoder?

- Maybe, we could train multiple encoders on different genres and use an ensemble in the final model, but idk

What kind of loss function would one use for this kind of thing? Is this more a task for reinforcement learning? I have some ideas for synthetic data generation, but if the dataset is a bunch of answers to "which of these 3 songs is the odd one out" how do we actually train a model on that when its inputs are just one song?

- It's very clear how to use that for validation (answer "when given the same songs, does the model agree?"), but training is specifically what I'm unsure about
- **Triplet loss** is a simple loss that says if a human says these 2 are similar it will make sure they are similar in the embedding space

## What tools (or languages) should be used?

The model can be implemented in pretty much anything for training, but inference has to be implemented in rust since that’s what the software this will be incorporated into is written in.

## Things I won’t consider

- Using the Spotify API: this defeats the whole purpose of MECOMP, and not all songs are on Spotify
- Rewriting MECOMP in some other language (Python) to make use of a more developed ml ecosystem (PyTorch): I’ve out almost 600 hours into developing MECOMP, rust has worked well and Python can’t meet my performance requirements (concurrency)

## Training data

we can use the Free Music Archive music dataset for our actual audio

<https://github.com/mdeff/fma>