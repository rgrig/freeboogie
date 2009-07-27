package genericutils;

import java.util.*;

import com.google.common.collect.Lists;

public class StringUtil {
  private StringUtil() { /* prevent instantiation of utility class */ }

  /*
    Splits into lines a text, trying to minimize sum(x^2), where
    x is the slack. The slack on the last line is ignored. Also,
    the text is justified (fills the line).
   */
  public static List<String> format(String text, int width) {
    ArrayList<String> words = Lists.newArrayList();
    Scanner s = new Scanner(text);
    while (s.hasNext()) {
      String word = s.next();
      words.add(word);
    }
    int[] nextLine = new int[words.size()];
    int[] slackPerLine = new int[words.size()];
    int[] score = new int[words.size()];
    int i = words.size(), j;
    while (--i >= 0) {
      score[i] = Integer.MAX_VALUE;
      int slack = width - words.get(i).length();
      j = i + 1;
      while (j < words.size()) {
        int newScore = slack * slack + score[j];
        if (newScore < score[i]) {
          score[i] = newScore;
          slackPerLine[i] = slack;
          nextLine[i] = j;
        }
        slack -= 1 + words.get(j++).length();
        if (slack < 0) break;
      }
      if (j == words.size() && (slack > 0 || j==i+1)) {
        score[i] = 0;
        slackPerLine[i] = 0;
        nextLine[i] = words.size();
      }
    }

    Random rand = new Random(0);
    List<String> result = Lists.newArrayList();
    for (i = 0; i < words.size(); i = nextLine[i]) {
      StringBuilder sb = new StringBuilder();
      int oneSpace = 1;
      int gaps = nextLine[i] - i - 1;
      int extra = 0;
      if (gaps > 0 && nextLine[i] < words.size()) {
        oneSpace = slackPerLine[i] / gaps + 1;
        extra = slackPerLine[i] % gaps;
      }
      for (j = i; j < nextLine[i]; ++j) {
        if (j != i) {
          for (int k = 0; k < oneSpace; ++k) sb.append(" ");
          if (rand.nextInt(gaps) < extra) {
            --extra;
            sb.append(" ");
          }
          --gaps;
        }
        sb.append(words.get(j));
      }
      result.add(sb.toString());
    }
    return result;
  }
}
