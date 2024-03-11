defmodule Minesweeper do

  def get_arr([h|_t], 0), do: h
  def get_arr([_h|t], n), do: get_arr(t, n-1)

  def update_arr([_h|t],0,v), do: [v | t]
  def update_arr([h|t],n,v), do: [h | update_arr(t, n-1, v)]

  def get_pos(tab,l,c), do: tab |> get_arr(l) |> get_arr(c)

  def update_pos(tab,l,c,v), do: update_arr(tab, l, get_arr(tab, l) |> update_arr(c, v))

  def is_mine(tab,l,c), do: get_pos(tab, l, c)

  def is_valid_pos(tamanho,l,c), do: l < tamanho && l >= 0 && c < tamanho && c >= 0

  def valid_moves(tam,l,c), do: filter([{l-1, c-1},{l-1, c},{l-1, c+1},{l, c-1},{l, c+1},{l+1, c-1},{l+1,c},{l+1,c+1}], tam)

  def filter([], _tam), do: []

  def filter([h | t], tam) do
    cond do
        is_valid_pos(tam, elem(h, 0), elem(h,1)) -> [h | filter(t, tam)]
        true -> filter(t, tam)
    end
  end

  def conta_minas_adj(tab,l,c) do
    _conta_minas(valid_moves(length(tab), l, c), tab, 0)
  end

  def _conta_minas([], _tab, counter), do: counter

  def _conta_minas([h | t], tab, counter) do
    cond do
        is_mine(tab, elem(h, 0), elem(h, 1)) -> _conta_minas(t, tab, counter + 1)
        true -> _conta_minas(t, tab, counter)
    end
  end

  def abre_jogada(l,c,minas,tab) do
     cond do
        is_mine(minas, l, c) -> tab
        get_pos(tab, l, c) != "-" -> tab
        conta_minas_adj(minas, l, c) > 0 -> update_pos(tab, l, c, conta_minas_adj(minas, l, c))
        true -> _abre_jogada(valid_moves(length(tab), l, c), minas, tab, {l, c})
     end
  end

  def _abre_jogada(list, minas, tab, tuple) do
    novo_tab = update_pos(tab, elem(tuple, 0), elem(tuple, 1), "0")
    _abre_jogada(list, minas, novo_tab)
  end

  def _abre_jogada([h | t], minas, tab) do
    novo_tab = abre_jogada(elem(h, 0), elem(h, 1), minas, tab)
    _abre_jogada(t, minas, novo_tab)
  end

  def _abre_jogada([], _minas, tab), do: tab

  def abre_posicao(tab,minas,l,c) do
    cond do
        is_mine(minas, l, c) -> update_pos(tab, l, c, "*")
        get_pos(tab, l, c) == "-" ->  update_pos(tab, l, c, conta_minas_adj(minas, l, c))
        true -> tab
    end
  end

  def abre_tabuleiro(minas,tab) do
    _abre_tabuleiro(tab, minas, 0, 0)
  end

  def _abre_tabuleiro(tab, minas, c, c2) do
    novo_tab = abre_posicao(tab, minas, c, c2)
    cond do
      c2 + 1 < length(tab) -> _abre_tabuleiro(novo_tab, minas, c, c2 + 1)
      c + 1 < length(tab) -> _abre_tabuleiro(novo_tab, minas, c + 1, 0)
      true -> tab
    end
  end

  def board_to_string(tab) do
    IO.write("\n")
    IO.write("  ")
    print_header(length(tab), 0)
    print_lines(tab, length(tab), 0)
  end

  def print_header(length, c) do
    IO.write(c)
    IO.write(" ")
    cond do
      c + 1 < length -> print_header(length, c + 1)
      true -> IO.write("\n")
    end
  end

  def print_lines([h | t], length, c) do
    print_line(h, c)
    cond do
      c + 1 < length ->  print_lines(t, length, c + 1)
      true -> nil
    end
  end

  def print_line(l, c) do
    IO.write(c)
    IO.write(" ")
    _print_line(l)
  end

  def _print_line([]), do: IO.write("\n")

  def _print_line([h | t]) do
    IO.write(h)
    IO.write(" ")
    _print_line(t)
  end


  def gera_lista(0,_v), do: []
  def gera_lista(n,v), do: [v | gera_lista(n - 1, v)]

  def gera_tabuleiro(n), do: gera_lista(n, gera_lista(n, "-"))

  def gera_mapa_de_minas(n), do: gera_lista(n, gera_lista(n, false))

  def conta_fechadas(tab) do
    _conta_fechadas1(tab, 0)
  end

  def _conta_fechadas1([], _c), do: 0

  def _conta_fechadas1([h | t], c) do
    _conta_fechadas2(h, c) + _conta_fechadas1(t, 0)
  end

  def _conta_fechadas2([], c), do: c

  def _conta_fechadas2([h | t], c) do
    cond do
      h == "-" -> _conta_fechadas2(t, c + 1)
      true -> _conta_fechadas2(t, c)
    end
  end

  def conta_minas(minas) do
    _conta_minas1(minas, 0)
  end

  def _conta_minas1([], _c), do: 0

  def _conta_minas1([h | t], c) do
    _conta_minas2(h, c) + _conta_minas1(t, 0)
  end

  def _conta_minas2([], c), do: c

  def _conta_minas2([h | t], c) do
    cond do
      h == true -> _conta_minas2(t, c + 1)
      true -> _conta_minas2(t, c)
    end
  end

  def end_game(minas,tab), do:  conta_fechadas(tab) == conta_minas(minas)

end

defmodule Motor do
def main() do
 v = IO.gets("Digite o tamanho do tabuleiro: \n")
 {size,_} = Integer.parse(v)
 minas = gen_mines_board(size)
 IO.inspect minas
 tabuleiro = Minesweeper.gera_tabuleiro(size)
 IO.write("done")
 game_loop(minas,tabuleiro)
end
def game_loop(minas,tabuleiro) do
  IO.write Minesweeper.board_to_string(tabuleiro)
  v = IO.gets("Digite uma linha: \n")
  {linha,_} = Integer.parse(v)
  v = IO.gets("Digite uma coluna: \n")
  {coluna,_} = Integer.parse(v)
  if (Minesweeper.is_mine(minas,linha,coluna)) do
    IO.write "VOCÊ PERDEU!!!!!!!!!!!!!!!!"
    IO.write Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas,tabuleiro))
    IO.write "TENTE NOVAMENTE!!!!!!!!!!!!"
  else
    novo_tabuleiro = Minesweeper.abre_jogada(linha,coluna,minas,tabuleiro)
    if (Minesweeper.end_game(minas,novo_tabuleiro)) do
        IO.write "VOCÊ VENCEU!!!!!!!!!!!!!!"
        IO.write Minesweeper.board_to_string(Minesweeper.abre_tabuleiro(minas,novo_tabuleiro))
        IO.write "PARABÉNS!!!!!!!!!!!!!!!!!"
    else
        game_loop(minas,novo_tabuleiro)
    end
  end
end
def gen_mines_board(size) do
  add_mines(ceil(size*size*0.15), size, Minesweeper.gera_mapa_de_minas(size))
end
def add_mines(0,_size,mines), do: mines
def add_mines(n,size,mines) do
  linha = :rand.uniform(size-1)
  coluna = :rand.uniform(size-1)
  if Minesweeper.is_mine(mines,linha,coluna) do
    add_mines(n,size,mines)
  else
    add_mines(n-1,size,Minesweeper.update_pos(mines,linha,coluna,true))
  end
end
end

Motor.main()
