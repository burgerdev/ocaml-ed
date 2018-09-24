open OUnit

open Ed

(* Simple input-to-output tests based on RFC 7748, Section 5.2. *)

type case = {priv: string; pub: string; exp: string}

let black_box_test: (module S) -> case -> test_fun = fun m {priv; pub; exp} _ ->
  let module M = (val m) in
  let priv = M.private_key_of_string priv in
  let pub = M.public_key_of_string pub in
  let out = M.scale priv pub |> M.string_of_public_key in
  assert_equal exp out

let x25519_simple =
  [ { priv="a546e36bf0527c9d3b16154b82465edd62144c0ac1fc5a18506a2244ba449ac4"
    ; pub="e6db6867583030db3594c1a424b15f7c726624ec26b3353b10a903a6d0ab1c4c"
    ; exp="c3da55379de9c6908e94ea4df28d084f32eccf03491c71f754b4075577a28552"}
  ; { priv="4b66e9d4d1b4673c5ad22691957d6af5c11b6421e0ea01d42ca4169e7918ba0d"
    ; pub="e5210f12786811d3f4b7959d0538ae2c31dbe7106fc03c3efc4cd549c715a493"
    ; exp="95cbde9476e8907d7aade45cb4b873f88b595a68799fa152e6f8f7647aac7957"}]
  |> List.map @@ black_box_test (module X25519)
  |> List.map @@ fun f -> "simple" >:: f

let x448_simple =
  [ { priv="3d262fddf9ec8e88495266fea19a34d28882acef045104d0d1aae121700a779c984c24f8cdd78fbff44943eba368f54b29259a4f1c600ad3"
    ; pub="06fce640fa3487bfda5f6cf2d5263f8aad88334cbd07437f020f08f9814dc031ddbdc38c19c6da2583fa5429db94ada18aa7a7fb4ef8a086"
    ; exp="ce3e4ff95a60dc6697da1db1d85e6afbdf79b50a2412d7546d5f239fe14fbaadeb445fc66a01b0779d98223961111e21766282f73dd96b6f"}
  ; { priv="203d494428b8399352665ddca42f9de8fef600908e0d461cb021f8c538345dd77c3e4806e25f46d3315c44e0a5b4371282dd2c8d5be3095f"
    ; pub="0fbcc2f993cd56d3305b0b7d9e55d4c1a8fb5dbb52f8e9a1e9b6201b165d015894e56c4d3570bee52fe205e28a78b91cdfbde71ce8d157db"
    ; exp="884a02576239ff7a2f2f63b2db6a9ff37047ac13568e1e30fe63c4a7ad1b3ee3a5700df34321d62077e63633c575c1c954514e99da7c179d"}]
  |> List.map @@ black_box_test (module X448)
  |> List.map @@ fun f -> "simple" >:: f


(* Repeated iteration based on RFC 7748, Section 5.2. *)

type case2 = {start: string; iter: int; exp: string}

let black_box_test: (module S) -> case2 -> test_fun = fun m {start; iter; exp} _ ->
  let module M = (val m) in
  let rec apply k u = function
    | 0 -> k
    | n ->
      let pub = M.public_key_of_string u in
      let priv = M.private_key_of_string k in
      apply (M.scale priv pub |> M.string_of_public_key) k (n - 1)
  in

  let out = apply start start iter in
  assert_equal exp out

let x25519_rep =
  [ { start="0900000000000000000000000000000000000000000000000000000000000000"
    ; iter=1
    ; exp="422c8e7a6227d7bca1350b3e2bb7279f7897b87bb6854b783c60e80311ae3079"}
  ; { start="0900000000000000000000000000000000000000000000000000000000000000"
    ; iter=1000
    ; exp="684cf59ba83309552800ef566f2f4d3c1c3887c49360e3875f2eb94d99532c51"}]
  |> List.map @@ black_box_test (module X25519)
  |> List.map @@ fun f -> "repeated" >:: f

let x448_rep =
  [ { start="0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    ; iter=1
    ; exp="3f482c8a9f19b01e6c46ee9711d9dc14fd4bf67af30765c2ae2b846a4d23a8cd0db897086239492caf350b51f833868b9bc2b3bca9cf4113"}
  ; { start="0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    ; iter=1000
    ; exp="aa3b4749d55b9daf1e5b00288826c467274ce3ebbdd5c17b975e09d4af6c67cf10d087202db88286e2b79fceea3ec353ef54faa26e219f38"}]
  |> List.map @@ black_box_test (module X448)
  |> List.map @@ fun f -> "repeated" >:: f

let _ =
  "RFC_7748_Suite" >::: [ "X25519" >::: x25519_simple @ x25519_rep
                        ; "X448" >::: x448_simple @ x448_rep]
  |> run_test_tt_main
