package freeboogie.editor.eclipse;

import org.eclipse.ui.editors.text.TextEditor;

/**
 * The editor.
 * @author rgrig
 */
public class BoogieEditor extends TextEditor {

  private final ColorManager colorManager;

  /** constructor */
  public BoogieEditor() {
    super();
    colorManager = new ColorManager();
    setSourceViewerConfiguration(new BoogieConfiguration(colorManager));
    setDocumentProvider(new BoogieDocumentProvider());
  }

  @Override
  public void dispose() {
    colorManager.dispose();
    super.dispose();
  }

}
