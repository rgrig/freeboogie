package freeboogie.editor.eclipse;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.jface.text.presentation.IPresentationReconciler;
import org.eclipse.jface.text.presentation.PresentationReconciler;
import org.eclipse.jface.text.rules.DefaultDamagerRepairer;
import org.eclipse.jface.text.rules.Token;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.SourceViewerConfiguration;

public class BoogieConfiguration extends SourceViewerConfiguration {
  private BoogieScanner scanner;
  private final ColorManager colorManager;

  public BoogieConfiguration(final ColorManager colorManager) {
    this.colorManager = colorManager;
  }

  @Override
  public String[] getConfiguredContentTypes(final ISourceViewer sourceViewer) {
    return new String[] { 
        IDocument.DEFAULT_CONTENT_TYPE,
        BoogiePartitionScanner.XML_COMMENT, 
        BoogiePartitionScanner.XML_TAG };
  }

  protected BoogieScanner getBoogieScanner() {
    if (scanner == null) {
      scanner = new BoogieScanner(colorManager);
      scanner.setDefaultReturnToken(new Token(
          new TextAttribute(colorManager.getColor(
              IBoogieColorConstants.DEFAULT))));
    }
    return scanner;
  }

  @Override
  public IPresentationReconciler getPresentationReconciler(
      final ISourceViewer sourceViewer) 
  {
    final PresentationReconciler reconciler = new PresentationReconciler();

    DefaultDamagerRepairer dr = new DefaultDamagerRepairer(getBoogieScanner());
    reconciler.setDamager(dr, IDocument.DEFAULT_CONTENT_TYPE);
    reconciler.setRepairer(dr, IDocument.DEFAULT_CONTENT_TYPE);

    return reconciler;
  }

}
