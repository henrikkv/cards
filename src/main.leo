import zk_bitwise_stack_v0_0_1.leo;

program cards.aleo {
    mapping games: address => Game;
    record UnshuffledDeck {
        owner: address;
        deck: [[u128; 26]; 2];
        num_players: u8;
        player1: address;
        player2: address;
        player3: address;
        player4: address;
        player5: address;
    }
    inline get_new_deck() -> [[u128; 26]; 2] {
        return [[1u128, 2u128, 3u128, 4u128, 5u128, 6u128, 7u128, 8u128, 9u128, 10u128, 11u128, 12u128, 13u128, 14u128, 15u128, 16u128, 17u128, 18u128, 19u128, 20u128, 21u128, 22u128, 23u128, 24u128, 25u128, 26u128],
                [27u128, 28u128, 29u128, 30u128, 31u128, 32u128, 33u128, 34u128, 35u128, 36u128, 37u128, 38u128, 39u128, 40u128, 41u128, 42u128, 43u128, 44u128, 45u128, 46u128, 47u128, 48u128, 49u128, 50u128, 51u128, 52u128]];
    }

    struct Game {
        password_hash: u32,
        players_joined: u8,
        player1: address, // Max 5 players.
        player2: address,
        player3: address,
        player4: address,
        player5: address,
        buy_in: u64,
        deck: [[u128; 26]; 2],
    }
    transition start_shuffle(game: Game, e: u128, n: u128) -> UnshuffledDeck {
        let encryptedDeck: [[u128;26]; 2] = encrypt_deck(e, n, game.deck);
//      let shuffledEncryptedDeck: [[u128; 26]; 2] = shuffle_deck(nn, member_size, encryptedDeck[0u8], encrtyptedDeck[1u8]);
        let deck: UnshuffledDeck = UnshuffledDeck {
        owner: game.player2,
        deck: encryptedDeck,
        num_players: game.players_joined,
        player1: game.player1,
        player2: game.player2,
        player3: game.player3,
        player4: game.player4,
        player5: game.player5,
        };
        // Verify on chain that the initial deck is the same as the game deck.
        return deck then finalize(game, self.caller);
    }
    finalize start_shuffle(game: Game, playerOne: address) {
        let realGame: Game = Mapping::get(games, playerOne);
        // Fail if the game was modified for the transition.
        assert(game == realGame);
    }
    transition shuffle_and_pass(deck: UnshuffledDeck, e: u128, n: u128) -> UnshuffledDeck {
        let encryptedDeck: [[u128;26]; 2] = encrypt_deck(e, n, deck.deck);
        let newDeck: UnshuffledDeck = UnshuffledDeck {
            owner: deck.player3,
            deck: encryptedDeck,
            num_players: deck.num_players,
            player1: deck.player1,
            player2: deck.player2,
            player3: deck.player3,
            player4: deck.player4,
            player5: deck.player5,
        };
        return newDeck;
    }
    transition complete_the_shuffle(deck: UnshuffledDeck, playerOne: address) -> UnshuffledDeck {
        // If the owner of the record is player1, everyone has shuffled.
        assert_eq(deck.owner, deck.player1);
        assert_eq(deck.owner, self.caller);
        return then finalize(deck.deck, deck.player1);
    }
    finalize complete_the_shuffle(deck: [[u128; 26]; 2], playerOne: address) {
        let game: Game = Mapping::get(games, playerOne);
        // Update the deck
        Mapping::set(games, playerOne, game);
    }

    transition create_game(numPlayers: u8, password: u32) -> Game {
        let newGame: Game = Game {
            password_hash: SHA3_256::hash_to_u32(password),
            players_joined: 1u8,
            player1: self.caller,
            player2: 0u128 as address,
            player3: 0u128 as address,
            player4: 0u128 as address,
            player5: 0u128 as address,
            buy_in: 100u64,
            deck: get_new_deck(),
        };
        return then finalize(newGame, self.caller);
    }
    finalize create_game(game: Game, creator: address) {
        Mapping::set(games, creator, game);
    }

    transition join_game(playerOne: address, password: u32, randomSeed: u32) {
        let passwordHash: u32 = SHA3_256::hash_to_u32(password) as u32;
        return then finalize(playerOne, passwordHash, self.caller);
    }
    finalize join_game(playerOne: address, passwordHash: u32, joiningPlayer: address) {
        let game: Game = Mapping::get(games, playerOne);
        assert(game.players_joined < 5u8); // Don't overflow array.
        assert_eq(game.password_hash, passwordHash);
        let playersJoined: u8 = game.players_joined + 1u8;
        // Add new player to the list of players.
        if game.player2 == 0u128 as address {
            let newPlayer: address = joiningPlayer;
            let newGame: Game = Game {
                password_hash: passwordHash,
                players_joined: playersJoined,
                player1: playerOne,
                player2: newPlayer,
                player3: game.player3,
                player4: game.player4,
                player5: game.player5,
                buy_in:  game.buy_in,
                deck:    game.deck,
            };   
            Mapping::set(games, playerOne, newGame);
            return;
        }
        if game.player3 == 0u128 as address {
            let newPlayer: address = joiningPlayer;
            let newGame: Game = Game {
                password_hash: passwordHash,
                players_joined: playersJoined,
                player1: playerOne,
                player2: game.player2,
                player3: newPlayer,
                player4: game.player4,
                player5: game.player5,
                buy_in:  game.buy_in,
                deck:    game.deck,
            };   
            Mapping::set(games, playerOne, newGame);
            return;
        }
        if game.player4 == 0u128 as address {
            let newPlayer: address = joiningPlayer;
            let newGame: Game = Game {
                password_hash: passwordHash,
                players_joined: playersJoined,
                player1: playerOne,
                player2: game.player2,
                player3: game.player3,
                player4: newPlayer,
                player5: game.player5,
                buy_in:  game.buy_in,
                deck:    game.deck,
            };   
            Mapping::set(games, playerOne, newGame);
            return;
        }
        if game.player5 == 0u128 as address {
            let newPlayer: address = joiningPlayer;
            let newGame: Game = Game {
                password_hash: passwordHash,
                players_joined: playersJoined,
                player1: playerOne,
                player2: game.player2,
                player3: game.player3,
                player4: game.player4,
                player5: newPlayer,
                buy_in:  game.buy_in,
                deck:    game.deck,
            };   
            Mapping::set(games, playerOne, newGame);
            return;
        }
    }
    transition begin_game() {
        
    }

    // Encryption -------------------------------------------------------------------
    inline exp_by_squaring(base: u128, exp: u128, modulus: u128) -> u128 {
        let result: u128 = 1u128;
        let current_base: u128 = base;

        for i: u8 in 0u8..32u8 {
            if (exp % 2u128 == 1u128) { 
                result = (result * current_base) % modulus;
            }
            current_base = (current_base * current_base) % modulus;
            exp >>= 1u8; // divide by two
        }

        return result as u128;
    }
    
    inline encrypt_deck(e: u128, n: u128, deck: [[u128; 26]; 2]) -> [[u128; 26]; 2] {
        let bottom_half: [u128; 26] = deck[0u8];
        let top_half: [u128; 26] = deck[1u8];
         let t0: u128 = exp_by_squaring(bottom_half[0u8], e, n);
        let t1: u128 = exp_by_squaring(bottom_half[1u8], e, n);
        let t2: u128 = exp_by_squaring(bottom_half[2u8], e, n);
        let t3: u128 = exp_by_squaring(bottom_half[3u8], e, n);
        let t4: u128 = exp_by_squaring(bottom_half[4u8], e, n);
        let t5: u128 = exp_by_squaring(bottom_half[5u8], e, n);
        let t6: u128 = exp_by_squaring(bottom_half[6u8], e, n);
        let t7: u128 = exp_by_squaring(bottom_half[7u8], e, n);
        let t8: u128 = exp_by_squaring(bottom_half[8u8], e, n);
        let t9: u128 = exp_by_squaring(bottom_half[9u8], e, n);
        let t10: u128 = exp_by_squaring(bottom_half[10u8], e, n);
        let t11: u128 = exp_by_squaring(bottom_half[11u8], e, n);
        let t12: u128 = exp_by_squaring(bottom_half[12u8], e, n);
        let t13: u128 = exp_by_squaring(bottom_half[13u8], e, n);
        let t14: u128 = exp_by_squaring(bottom_half[14u8], e, n);
        let t15: u128 = exp_by_squaring(bottom_half[15u8], e, n);
        let t16: u128 = exp_by_squaring(bottom_half[16u8], e, n);
        let t17: u128 = exp_by_squaring(bottom_half[17u8], e, n);
        let t18: u128 = exp_by_squaring(bottom_half[18u8], e, n);
        let t19: u128 = exp_by_squaring(bottom_half[19u8], e, n);
        let t20: u128 = exp_by_squaring(bottom_half[20u8], e, n);
        let t21: u128 = exp_by_squaring(bottom_half[21u8], e, n);
        let t22: u128 = exp_by_squaring(bottom_half[22u8], e, n);
        let t23: u128 = exp_by_squaring(bottom_half[23u8], e, n);
        let t24: u128 = exp_by_squaring(bottom_half[24u8], e, n);
        let t25: u128 = exp_by_squaring(bottom_half[25u8], e, n);
        let t26: u128 = exp_by_squaring(top_half[0u8], e, n);
        let t27: u128 = exp_by_squaring(top_half[1u8], e, n);
        let t28: u128 = exp_by_squaring(top_half[2u8], e, n);
        let t29: u128 = exp_by_squaring(top_half[3u8], e, n);
        let t30: u128 = exp_by_squaring(top_half[4u8], e, n);
        let t31: u128 = exp_by_squaring(top_half[5u8], e, n);
        let t32: u128 = exp_by_squaring(top_half[6u8], e, n);
        let t33: u128 = exp_by_squaring(top_half[7u8], e, n);
        let t34: u128 = exp_by_squaring(top_half[8u8], e, n);
        let t35: u128 = exp_by_squaring(top_half[9u8], e, n);
        let t36: u128 = exp_by_squaring(top_half[10u8], e, n);
        let t37: u128 = exp_by_squaring(top_half[11u8], e, n);
        let t38: u128 = exp_by_squaring(top_half[12u8], e, n);
        let t39: u128 = exp_by_squaring(top_half[13u8], e, n);
        let t40: u128 = exp_by_squaring(top_half[14u8], e, n);
        let t41: u128 = exp_by_squaring(top_half[15u8], e, n);
        let t42: u128 = exp_by_squaring(top_half[16u8], e, n);
        let t43: u128 = exp_by_squaring(top_half[17u8], e, n);
        let t44: u128 = exp_by_squaring(top_half[18u8], e, n);
        let t45: u128 = exp_by_squaring(top_half[19u8], e, n);
        let t46: u128 = exp_by_squaring(top_half[20u8], e, n);
        let t47: u128 = exp_by_squaring(top_half[21u8], e, n);
        let t48: u128 = exp_by_squaring(top_half[22u8], e, n);
        let t49: u128 = exp_by_squaring(top_half[23u8], e, n);
        let t50: u128 = exp_by_squaring(top_half[24u8], e, n);
        let t51: u128 = exp_by_squaring(top_half[25u8], e, n);
        return [[t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10,
                 t11, t12, t13, t14, t15, t16, t17, t18, t19, t20,
                 t21, t22, t23, t24, t25],
                [t26, t27, t28, t29, t30, t31, t32, t33, t34, t35,
                 t36, t37, t38, t39, t40, t41, t42, t43, t44, t45,
                 t46, t47, t48, t49, t50, t51]];
    }

    transition decrypt_deck(d: u128, n: u128, deck: [[u128; 26]; 2]) -> [[u128; 26]; 2] {
        let bottom_half: [u128; 26] = deck[0u8];
        let top_half: [u128; 26] = deck[1u8];
        let t0: u128 = exp_by_squaring(bottom_half[0u8], d, n);
        let t1: u128 = exp_by_squaring(bottom_half[1u8], d, n);
        let t2: u128 = exp_by_squaring(bottom_half[2u8], d, n);
        let t3: u128 = exp_by_squaring(bottom_half[3u8], d, n);
        let t4: u128 = exp_by_squaring(bottom_half[4u8], d, n);
        let t5: u128 = exp_by_squaring(bottom_half[5u8], d, n);
        let t6: u128 = exp_by_squaring(bottom_half[6u8], d, n);
        let t7: u128 = exp_by_squaring(bottom_half[7u8], d, n);
        let t8: u128 = exp_by_squaring(bottom_half[8u8], d, n);
        let t9: u128 = exp_by_squaring(bottom_half[9u8], d, n);
        let t10: u128 = exp_by_squaring(bottom_half[10u8], d, n);
        let t11: u128 = exp_by_squaring(bottom_half[11u8], d, n);
        let t12: u128 = exp_by_squaring(bottom_half[12u8], d, n);
        let t13: u128 = exp_by_squaring(bottom_half[13u8], d, n);
        let t14: u128 = exp_by_squaring(bottom_half[14u8], d, n);
        let t15: u128 = exp_by_squaring(bottom_half[15u8], d, n);
        let t16: u128 = exp_by_squaring(bottom_half[16u8], d, n);
        let t17: u128 = exp_by_squaring(bottom_half[17u8], d, n);
        let t18: u128 = exp_by_squaring(bottom_half[18u8], d, n);
        let t19: u128 = exp_by_squaring(bottom_half[19u8], d, n);
        let t20: u128 = exp_by_squaring(bottom_half[20u8], d, n);
        let t21: u128 = exp_by_squaring(bottom_half[21u8], d, n);
        let t22: u128 = exp_by_squaring(bottom_half[22u8], d, n);
        let t23: u128 = exp_by_squaring(bottom_half[23u8], d, n);
        let t24: u128 = exp_by_squaring(bottom_half[24u8], d, n);
        let t25: u128 = exp_by_squaring(bottom_half[25u8], d, n);
        let t26: u128 = exp_by_squaring(top_half[0u8], d, n);
        let t27: u128 = exp_by_squaring(top_half[1u8], d, n);
        let t28: u128 = exp_by_squaring(top_half[2u8], d, n);
        let t29: u128 = exp_by_squaring(top_half[3u8], d, n);
        let t30: u128 = exp_by_squaring(top_half[4u8], d, n);
        let t31: u128 = exp_by_squaring(top_half[5u8], d, n);
        let t32: u128 = exp_by_squaring(top_half[6u8], d, n);
        let t33: u128 = exp_by_squaring(top_half[7u8], d, n);
        let t34: u128 = exp_by_squaring(top_half[8u8], d, n);
        let t35: u128 = exp_by_squaring(top_half[9u8], d, n);
        let t36: u128 = exp_by_squaring(top_half[10u8], d, n);
        let t37: u128 = exp_by_squaring(top_half[11u8], d, n);
        let t38: u128 = exp_by_squaring(top_half[12u8], d, n);
        let t39: u128 = exp_by_squaring(top_half[13u8], d, n);
        let t40: u128 = exp_by_squaring(top_half[14u8], d, n);
        let t41: u128 = exp_by_squaring(top_half[15u8], d, n);
        let t42: u128 = exp_by_squaring(top_half[16u8], d, n);
        let t43: u128 = exp_by_squaring(top_half[17u8], d, n);
        let t44: u128 = exp_by_squaring(top_half[18u8], d, n);
        let t45: u128 = exp_by_squaring(top_half[19u8], d, n);
        let t46: u128 = exp_by_squaring(top_half[20u8], d, n);
        let t47: u128 = exp_by_squaring(top_half[21u8], d, n);
        let t48: u128 = exp_by_squaring(top_half[22u8], d, n);
        let t49: u128 = exp_by_squaring(top_half[23u8], d, n);
        let t50: u128 = exp_by_squaring(top_half[24u8], d, n);
        let t51: u128 = exp_by_squaring(top_half[25u8], d, n);
        return [[t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10,
                 t11, t12, t13, t14, t15, t16, t17, t18, t19, t20,
                 t21, t22, t23, t24, t25],
                [t26, t27, t28, t29, t30, t31, t32, t33, t34, t35,
                 t36, t37, t38, t39, t40, t41, t42, t43, t44, t45,
                 t46, t47, t48, t49, t50, t51]];
    }

    transition encrypt_deck_per_card(deck_e: [[u128; 26]; 2], n: u128, deck: [[u128; 26]; 2]) -> [[u128; 26]; 2] {
        let bottom_half: [u128; 26] = deck[0u8];
        let top_half: [u128; 26] = deck[1u8];
        let bottom_half_e: [u128; 26] = deck_e[0u8];
        let top_half_e: [u128; 26] = deck_e[1u8];
        // Encrypt per card
        let t0: u128 = exp_by_squaring(bottom_half[0u8], bottom_half_e[0u8], n);
        let t1: u128 = exp_by_squaring(bottom_half[1u8], bottom_half_e[1u8], n);
        let t2: u128 = exp_by_squaring(bottom_half[2u8], bottom_half_e[2u8], n);
        let t3: u128 = exp_by_squaring(bottom_half[3u8], bottom_half_e[3u8], n);
        let t4: u128 = exp_by_squaring(bottom_half[4u8], bottom_half_e[4u8], n);
        let t5: u128 = exp_by_squaring(bottom_half[5u8], bottom_half_e[5u8], n);
        let t6: u128 = exp_by_squaring(bottom_half[6u8], bottom_half_e[6u8], n);
        let t7: u128 = exp_by_squaring(bottom_half[7u8], bottom_half_e[7u8], n);
        let t8: u128 = exp_by_squaring(bottom_half[8u8], bottom_half_e[8u8], n);
        let t9: u128 = exp_by_squaring(bottom_half[9u8], bottom_half_e[9u8], n);
        let t10: u128 = exp_by_squaring(bottom_half[10u8], bottom_half_e[10u8], n);
        let t11: u128 = exp_by_squaring(bottom_half[11u8], bottom_half_e[11u8], n);
        let t12: u128 = exp_by_squaring(bottom_half[12u8], bottom_half_e[12u8], n);
        let t13: u128 = exp_by_squaring(bottom_half[13u8], bottom_half_e[13u8], n);
        let t14: u128 = exp_by_squaring(bottom_half[14u8], bottom_half_e[14u8], n);
        let t15: u128 = exp_by_squaring(bottom_half[15u8], bottom_half_e[15u8], n);
        let t16: u128 = exp_by_squaring(bottom_half[16u8], bottom_half_e[16u8], n);
        let t17: u128 = exp_by_squaring(bottom_half[17u8], bottom_half_e[17u8], n);
        let t18: u128 = exp_by_squaring(bottom_half[18u8], bottom_half_e[18u8], n);
        let t19: u128 = exp_by_squaring(bottom_half[19u8], bottom_half_e[19u8], n);
        let t20: u128 = exp_by_squaring(bottom_half[20u8], bottom_half_e[20u8], n);
        let t21: u128 = exp_by_squaring(bottom_half[21u8], bottom_half_e[21u8], n);
        let t22: u128 = exp_by_squaring(bottom_half[22u8], bottom_half_e[22u8], n);
        let t23: u128 = exp_by_squaring(bottom_half[23u8], bottom_half_e[23u8], n);
        let t24: u128 = exp_by_squaring(bottom_half[24u8], bottom_half_e[24u8], n);
        let t25: u128 = exp_by_squaring(bottom_half[25u8], bottom_half_e[25u8], n);
        let t26: u128 = exp_by_squaring(top_half[0u8], top_half_e[0u8], n);
        let t27: u128 = exp_by_squaring(top_half[1u8], top_half_e[1u8], n);
        let t28: u128 = exp_by_squaring(top_half[2u8], top_half_e[2u8], n);
        let t29: u128 = exp_by_squaring(top_half[3u8], top_half_e[3u8], n);
        let t30: u128 = exp_by_squaring(top_half[4u8], top_half_e[4u8], n);
        let t31: u128 = exp_by_squaring(top_half[5u8], top_half_e[5u8], n);
        let t32: u128 = exp_by_squaring(top_half[6u8], top_half_e[6u8], n);
        let t33: u128 = exp_by_squaring(top_half[7u8], top_half_e[7u8], n);
        let t34: u128 = exp_by_squaring(top_half[8u8], top_half_e[8u8], n);
        let t35: u128 = exp_by_squaring(top_half[9u8], top_half_e[9u8], n);
        let t36: u128 = exp_by_squaring(top_half[10u8], top_half_e[10u8], n);
        let t37: u128 = exp_by_squaring(top_half[11u8], top_half_e[11u8], n);
        let t38: u128 = exp_by_squaring(top_half[12u8], top_half_e[12u8], n);
        let t39: u128 = exp_by_squaring(top_half[13u8], top_half_e[13u8], n);
        let t40: u128 = exp_by_squaring(top_half[14u8], top_half_e[14u8], n);
        let t41: u128 = exp_by_squaring(top_half[15u8], top_half_e[15u8], n);
        let t42: u128 = exp_by_squaring(top_half[16u8], top_half_e[16u8], n);
        let t43: u128 = exp_by_squaring(top_half[17u8], top_half_e[17u8], n);
        let t44: u128 = exp_by_squaring(top_half[18u8], top_half_e[18u8], n);
        let t45: u128 = exp_by_squaring(top_half[19u8], top_half_e[19u8], n);
        let t46: u128 = exp_by_squaring(top_half[20u8], top_half_e[20u8], n);
        let t47: u128 = exp_by_squaring(top_half[21u8], top_half_e[21u8], n);
        let t48: u128 = exp_by_squaring(top_half[22u8], top_half_e[22u8], n);
        let t49: u128 = exp_by_squaring(top_half[23u8], top_half_e[23u8], n);
        let t50: u128 = exp_by_squaring(top_half[24u8], top_half_e[24u8], n);
        let t51: u128 = exp_by_squaring(top_half[25u8], top_half_e[25u8], n);
        return [[t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10,
                 t11, t12, t13, t14, t15, t16, t17, t18, t19, t20,
                 t21, t22, t23, t24, t25],
                [t26, t27, t28, t29, t30, t31, t32, t33, t34, t35,
                 t36, t37, t38, t39, t40, t41, t42, t43, t44, t45,
                 t46, t47, t48, t49, t50, t51]];
    }

    transition test_encrypt_exp_by_squaring(public m: u128, e: u128, d: u128, n: u128) -> (u128, u128) {
      let c: u128 = exp_by_squaring(m, e, n);
      let p: u128 = exp_by_squaring(c, d, n);
      assert_eq(m, p);
      return (c, p);
    }

    transition test_exp_by_squaring(public m: u128, d1: u128, d2: u128, n: u128) -> (u128, u128) {
      let m1: u128 = exp_by_squaring(m, d1, n);
      let p: u128 = exp_by_squaring(m1, d2, n);
      return (m1, p);
    }


// Shuffling -------------------------------------------------------------------
    function setup_shuffle(element: i8, deck: [[u128; 26]; 2]) -> (i8, [u128; 26], [u128; 26]) {
        let n: i8 = element.abs();
        if (element < 0i8) {
            return (n, deck[0u8], deck[1u8]);
        } else {
            return (n, deck[1u8], deck[0u8]);
        }
    }

    transition shuffle_deck(n: i8, member_size: u8, a: [u128; 26], b: [u128; 26]) -> [[u128; 26]; 2] {
        assert(n >= 1i8);
        assert(n <= 26i8);
        let stack_a: Stack = zk_bitwise_stack_v0_0_1.leo/init_stack(member_size);
        let stack_b: Stack = zk_bitwise_stack_v0_0_1.leo/init_stack(member_size);
        let shuffled_stack: Stack = zk_bitwise_stack_v0_0_1.leo/init_stack(member_size);
        for i: u8 in 0u8..26u8 {
            stack_a = zk_bitwise_stack_v0_0_1.leo/push(a[i], stack_a);
        }
        for i: u8 in 0u8..26u8 {
            stack_b = zk_bitwise_stack_v0_0_1.leo/push(b[i], stack_b);
        }
        let a_index: u8 = 0u8;
        let b_index: u8 = 0u8;
        let tuple_card_stack: (u128, Stack) = (0u128, zk_bitwise_stack_v0_0_1.leo/init_stack(member_size));
        for i: i8 in 0i8..52i8 {
            let use_b: bool = false;
            let use_a: bool = false;
            if (i < n) {
                use_b = true;
                b_index += 1u8;
            }
            else if (((i - n) % 2i8 == 0i8)) {
                use_a = true;
                a_index += 1u8;
            }
            else if (b_index <= 25u8) {
                use_b = true;
                b_index += 1u8;
            } else {
                use_a = true;
                a_index += 1u8;
            }
            assert(use_a && !use_b || !use_a && use_b);
            if (use_b) {
                tuple_card_stack = zk_bitwise_stack_v0_0_1.leo/pop(stack_b);
                stack_b = tuple_card_stack.1;
                shuffled_stack = zk_bitwise_stack_v0_0_1.leo/push(tuple_card_stack.0, shuffled_stack);
            }
            else {
                tuple_card_stack = zk_bitwise_stack_v0_0_1.leo/pop(stack_a);
                stack_a = tuple_card_stack.1;
                shuffled_stack = zk_bitwise_stack_v0_0_1.leo/push(tuple_card_stack.0, shuffled_stack);
            }
        }
        let tuple: (u128, Stack) = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t0: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t1: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t2: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t3: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t4: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t5: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t6: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t7: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t8: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t9: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t10: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t11: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t12: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t13: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t14: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t15: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t16: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t17: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t18: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t19: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t20: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t21: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t22: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t23: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t24: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t25: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t26: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t27: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t28: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t29: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t30: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t31: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t32: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t33: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t34: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t35: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t36: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t37: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t38: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t39: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t40: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t41: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t42: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t43: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t44: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t45: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t46: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t47: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t48: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t49: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t50: u128 = tuple.0;
        shuffled_stack = tuple.1;
        tuple = zk_bitwise_stack_v0_0_1.leo/pop(shuffled_stack);
        let t51: u128 = tuple.0;
        shuffled_stack = tuple.1;

        return [[t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23, t24, t25],
                [t26, t27, t28, t29, t30, t31, t32, t33, t34, t35, t36, t37, t38, t39, t40, t41, t42, t43, t44, t45, t46, t47, t48, t49, t50, t51]];
    }
}